//
//  NodeView.swift
//  Actions
//
//  Created by Chris on 17/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

enum NodeColour: Int {
    case VeryLightGrey
    case LightGrey
    case Green
    case Red
    case LightRed
    case Blue
}

class NodeView: NSView {
    
    var pathLayer : CAShapeLayer
    private var _currentState = NodeState.Inactive
    
    required init?(coder: NSCoder) {
        
        pathLayer = CAShapeLayer()
        
        super.init(coder: coder)
        
        pathLayer.lineWidth = 0.5
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
                pathLayer.lineWidth = 0.5
                pathLayer.strokeColor = drawingContextColour(colourForState(currentState)).stroke
            }
            CATransaction.commit()
        }
    }
    
    var currentState: NodeState {
        get {
            return _currentState
        }
        set {
            _currentState = newValue
        }
    }
    
    func calculatePath() -> CGPath {
        fatalError("calculatePath MUST be overriden")
    }
    
    func updateViewToState(state:NodeState, shouldTransition:Bool) {
        if state != NodeState.Running && self.pathLayer.animationKeys()?.contains("RunningFill") == true  {
            self.pathLayer.removeAnimationForKey("RunningFill")
            self.pathLayer.removeAnimationForKey("RunningStroke")
        }
        
        switch state {
        case .Inactive:
            CATransaction.begin()
            CATransaction.setDisableActions(!shouldTransition)
            self.pathLayer.strokeColor = drawingContextColour(.LightGrey).stroke
            self.pathLayer.fillColor = drawingContextColour(.LightGrey).fill
            CATransaction.commit()
            
        case .Ready:
            CATransaction.begin()
            CATransaction.setDisableActions(!shouldTransition)
            self.pathLayer.strokeColor = drawingContextColour(.Green).stroke
            self.pathLayer.fillColor = drawingContextColour(.Green).fill
            CATransaction.commit()
            /*
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.pathLayer.strokeColor = drawingContextColour(.LightGrey).stroke
            self.pathLayer.fillColor = drawingContextColour(.LightGrey).fill
            CATransaction.commit()
            
             if shouldTransition == true {
                    let anim = CABasicAnimation(keyPath: "fillColor")
                    anim.fromValue = drawingContextColour(.Green).fill
                    anim.toValue = drawingContextColour(.LightGrey).fill
                    
                    let anim2 = CABasicAnimation(keyPath: "strokeColor")
                    anim2.fromValue = drawingContextColour(.Green).stroke
                    anim2.toValue = drawingContextColour(.LightGrey).stroke
                    
                    let group = CAAnimationGroup()
                    group.animations = [anim,anim2]
                    group.duration = 1.0
                    group.repeatCount = 0
                    group.autoreverses = false
                    group.removedOnCompletion = true
                    self.pathLayer.addAnimation(group, forKey: "ReadyAnimation")
            }
            //else {
            //    Swift.print("false")
            // }
 */
        
        case .Running:
            let anim = CABasicAnimation(keyPath: "fillColor")
            anim.fromValue = drawingContextColour(.Green).fill
            anim.toValue = drawingContextColour(.LightGrey).fill
            anim.repeatCount = Float.infinity
            anim.duration = 0.5
            anim.autoreverses = true
            self.pathLayer.addAnimation(anim, forKey: "RunningFill")
            
            let animStroke = CABasicAnimation(keyPath: "strokeColor")
            animStroke.fromValue = drawingContextColour(.Green).stroke
            animStroke.toValue = drawingContextColour(.LightGrey).stroke
            animStroke.repeatCount = Float.infinity
            animStroke.duration = 0.5
            animStroke.autoreverses = true
            self.pathLayer.addAnimation(animStroke, forKey: "RunningStroke")
            
        case .WaitingForUserInput, .InheritedWait:
            CATransaction.begin()
            CATransaction.setDisableActions(!shouldTransition)
            pathLayer.strokeColor = drawingContextColour(.Blue).stroke
            pathLayer.fillColor = drawingContextColour(.Blue).fill
            CATransaction.commit()
            
        case .Error:
            CATransaction.begin()
            CATransaction.setDisableActions(!shouldTransition)
            pathLayer.strokeColor = drawingContextColour(.Red).stroke
            pathLayer.fillColor = drawingContextColour(.Red).fill
            CATransaction.commit()
            
        case .InheritedError:
            CATransaction.begin()
            CATransaction.setDisableActions(!shouldTransition)
            pathLayer.strokeColor = drawingContextColour(.Red).stroke
            pathLayer.fillColor = drawingContextColour(.Red).fill
            CATransaction.commit()
            
        case .Completed:
            CATransaction.begin()
            CATransaction.setDisableActions(!shouldTransition)
            self.pathLayer.strokeColor = drawingContextColour(.LightGrey).stroke
            self.pathLayer.fillColor = drawingContextColour(.LightGrey).fill
            CATransaction.commit()
            
        case .Void: fatalError("Trying to add animation when stateNode = .Void")
        }
        currentState = state
    }
    
    func colourForState(state:NodeState) -> NodeColour {
        
        switch state {
        case .Inactive: return .LightGrey
        case .Ready: return .Green
        case .Running: return .Green
        case .Completed: return .LightGrey
        case .WaitingForUserInput: return .Blue
        case .InheritedWait: return .Blue
        case .Error: return .Red
        case .InheritedError: return .LightRed
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
    case .LightRed:
        return (AppConfiguration.Palette.lightRedFill.CGColor, AppConfiguration.Palette.lightRedStroke.CGColor)
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