//
//  NodeView.swift
//  Filament
//
//  Created by Chris on 17/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import Async

enum NodeColour: Int { case VeryLightGrey, LightGrey, Green, Red, Blue}

class NodeView: NSView {
    
    var pathLayer : CAShapeLayer
    
    required init?(coder: NSCoder) {
        
        pathLayer = CAShapeLayer()
        
        super.init(coder: coder)
        
        pathLayer.lineWidth = 0.8
        pathLayer.path = calculatePath()
        pathLayer.shouldRasterize = false
        pathLayer.strokeColor = drawingContextColour(.LightGrey).stroke
        pathLayer.fillColor = drawingContextColour(.LightGrey).fill
        
        self.wantsLayer = true
        self.layer?.addSublayer(pathLayer)
        self.layer?.masksToBounds = false
    }
    
    
    override func layout() {
        super.layout()
        
        pathLayer.path = calculatePath()
    }
    
    override var wantsDefaultClipping: Bool { return false }
    
    deinit {
    }
    
    var selected = false {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            if selected {
                pathLayer.lineWidth = 2.0
                if currentState == .Inactive || currentState == .Ready || currentState == .Completed {
                    pathLayer.strokeColor = AppConfiguration.Palette.selectionBlue.CGColor
                }
                
            } else {
                pathLayer.lineWidth = 0.8
                pathLayer.strokeColor = drawingContextColour(colourForState(currentState)).stroke
            }
            CATransaction.commit()
        }
    }
    
    var currentState:NodeState = .Inactive {
        willSet {
            if newValue == currentState { return }
            performAnimationsForNewState(newValue)
        }
        didSet {
            self.needsLayout = true
        }
    }
    
    func calculatePath() -> CGPath {
        fatalError("calculatePath MUST be overriden")
    }
    
    
    func performAnimationsForNewState(newState:NodeState) {
        
        if newState != NodeState.Running && self.pathLayer.animationKeys()?.contains("RunningFill") == true  {
            self.pathLayer.removeAllAnimations()
        }
        
        switch newState {
            
        case .Inactive:
            self.pathLayer.strokeColor = drawingContextColour(.LightGrey).stroke
            self.pathLayer.fillColor = drawingContextColour(.LightGrey).fill
            
        case .Ready:
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.pathLayer.strokeColor = drawingContextColour(.Green).stroke
            self.pathLayer.fillColor = drawingContextColour(.Green).fill
            CATransaction.commit()
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            self.pathLayer.strokeColor = drawingContextColour(.LightGrey).stroke
            self.pathLayer.fillColor = drawingContextColour(.LightGrey).fill
            CATransaction.commit()
            
        case .Running:
            let anim = CABasicAnimation(keyPath: "fillColor")
            anim.toValue = drawingContextColour(.Green).fill
            anim.fromValue = drawingContextColour(.LightGrey).fill
            anim.repeatCount = Float.infinity
            anim.duration = 0.5
            anim.autoreverses = true
            self.pathLayer.addAnimation(anim, forKey: "RunningFill")
            //   }
            
            // if self.pathLayer.animationKeys()?.contains("RunningStroke") == false {
            let animStroke = CABasicAnimation(keyPath: "strokeColor")
            animStroke.toValue = drawingContextColour(.Green).stroke
            animStroke.fromValue = drawingContextColour(.LightGrey).stroke
            animStroke.repeatCount = Float.infinity
            animStroke.duration = 0.5
            animStroke.autoreverses = true
            self.pathLayer.addAnimation(animStroke, forKey: "RunningStroke")
            
        case .WaitingForUserInput:
            pathLayer.strokeColor = drawingContextColour(.Blue).stroke
            pathLayer.fillColor = drawingContextColour(.Blue).fill
            
        case .Error:
            pathLayer.strokeColor = drawingContextColour(.Red).stroke
            pathLayer.fillColor = drawingContextColour(.Red).fill
            
        case .Completed:
            pathLayer.strokeColor = drawingContextColour(.VeryLightGrey).stroke
            pathLayer.fillColor = drawingContextColour(.VeryLightGrey).fill
            
        case .Void: fatalError("Trying to add animation when stateNode = .Void")
        }
    }
    
    
    func colourForState(state:NodeState) -> NodeColour {
        
        switch state {
        case .Inactive: return .LightGrey
        case .Ready: return .LightGrey
        case .Running: return .Green
        case .Completed: return .LightGrey
        case .WaitingForUserInput: return .Blue
        case .Error: return .Red
        case .Void: fatalError("Trying to find colour for a Void State")
        }
    }
}

func drawingContextColour(colour:NodeColour) -> (fill:CGColor, stroke:CGColor) {
    
    switch colour {
    case .VeryLightGrey:
        return (AppConfiguration.Palette.verylightGreyFill.CGColor, AppConfiguration.Palette.verylightGreyStroke.CGColor)
    case .LightGrey:
        return (AppConfiguration.Palette.lightGreyFill.CGColor, AppConfiguration.Palette.lightGreyStroke.CGColor)
    case .Green:
        return (AppConfiguration.Palette.greenFill.CGColor, AppConfiguration.Palette.greenStroke.CGColor)
    case .Red:
        return (AppConfiguration.Palette.redFill.CGColor, AppConfiguration.Palette.redStroke.CGColor)
    case .Blue:
        return (AppConfiguration.Palette.blueFill.CGColor, AppConfiguration.Palette.blueStroke.CGColor)
    }
}


extension NSBezierPath {
    
    func CGPath(forceClose forceClose:Bool) -> CGPathRef? {
        
        var cgPath:CGPathRef? = nil
        
        let numElements = self.elementCount
        if numElements > 0 {
            let newPath = CGPathCreateMutable()
            let points = NSPointArray.alloc(3)
            var bDidClosePath:Bool = true
            
            for i in 0 ..< numElements {
                
                switch elementAtIndex(i, associatedPoints:points) {
                    
                case NSBezierPathElement.MoveToBezierPathElement:
                    CGPathMoveToPoint(newPath, nil, points[0].x, points[0].y )
                    
                case NSBezierPathElement.LineToBezierPathElement:
                    CGPathAddLineToPoint(newPath, nil, points[0].x, points[0].y )
                    bDidClosePath = false
                    
                case NSBezierPathElement.CurveToBezierPathElement:
                    CGPathAddCurveToPoint(newPath, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y )
                    bDidClosePath = false
                    
                case NSBezierPathElement.ClosePathBezierPathElement:
                    CGPathCloseSubpath(newPath)
                    bDidClosePath = true
                }
                
                if forceClose && !bDidClosePath {
                    CGPathCloseSubpath(newPath)
                }
            }
            cgPath = CGPathCreateCopy(newPath)
        }
        return cgPath
    }
}