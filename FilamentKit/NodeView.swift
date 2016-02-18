//
//  NodeView.swift
//  Filament
//
//  Created by Chris on 17/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

enum NodeColour: Int { case LightGrey, Green, Red, Blue}

class NodeView: NSView {
    
    var pathLayer : CAShapeLayer
    
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
    }
    
    
    override func layout() {
        super.layout()
        
        pathLayer.path = calculatePath()
    }
    
    
    
    var selected = false {
        didSet {
            /*
            if selected {
                pathLayer.lineWidth = 2
                pathLayer.strokeColor = AppConfiguration.Palette.selectionBlue.CGColor
            } else {
               pathLayer.lineWidth = 0.6
               pathLayer.strokeColor = AppConfiguration.Palette.selectionBlue.CGColor
            }
*/
        }
    }
    
    var currentStatus:NodeStatus = .inActive {
        willSet {
            if newValue == currentStatus { return }
            performAnimationsForNewStatus(newValue)
        }
        
        didSet {
            self.needsLayout = true
        }
    }
    
    func calculatePath() -> CGPath {
        fatalError("calculatePath MUST be overriden")
    }
    
    
    func performAnimationsForNewStatus(newStatus:NodeStatus) {
        
        switch newStatus {
            
        case .inActive, .Completed:
            pathLayer.strokeColor = drawingContextColour(.LightGrey).stroke
            pathLayer.fillColor = drawingContextColour(.LightGrey).fill
            
        case .Ready:
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            pathLayer.strokeColor = drawingContextColour(.Green).stroke
            pathLayer.fillColor = drawingContextColour(.Green).fill
            CATransaction.commit()
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(2.0)
            pathLayer.strokeColor = drawingContextColour(.LightGrey).stroke
            pathLayer.fillColor = drawingContextColour(.LightGrey).fill
            CATransaction.commit()
            
            
        case .Running:
            pathLayer.strokeColor = drawingContextColour(.Green).stroke
            pathLayer.fillColor = drawingContextColour(.Green).fill

            
        case .WaitingForUserInput:
            pathLayer.strokeColor = drawingContextColour(.Blue).stroke
            pathLayer.fillColor = drawingContextColour(.Blue).fill
            
        case .Error:
            pathLayer.strokeColor = drawingContextColour(.Red).stroke
            pathLayer.fillColor = drawingContextColour(.Red).fill
            
        case .Void: fatalError("Trying to add animation when statusNode = .Void")
        }
    }


    func drawingContextColour(colour:NodeColour) -> (fill:CGColor, stroke:CGColor) {
 
        switch colour {
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
    
    func colourForStatus(status:NodeStatus) -> NodeColour {
        
        switch status {
        case .inActive: return .LightGrey
        case .Ready: return .LightGrey
        case .Running: return .Green
        case .Completed: return .LightGrey
        case .WaitingForUserInput: return .Blue
        case .Error: return .Red
        case .Void: fatalError("Trying to find colour for a Void Status")
        }
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


/*

// -------------------- MOUSE EVENTS ------------------- \\

- (BOOL) acceptsFirstMouse:(NSEvent *)e {
return YES;
}

- (void)mouseDown:(NSEvent *) e {

// Convert to superview's coordinate space
self.lastDragLocation = [[self superview] convertPoint:[e locationInWindow] fromView:nil];

}

- (void)mouseDragged:(NSEvent *)theEvent {

// We're working only in the superview's coordinate space, so we always convert.
NSPoint newDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
NSPoint thisOrigin = [self frame].origin;
thisOrigin.x += (-self.lastDragLocation.x + newDragLocation.x);
thisOrigin.y += (-self.lastDragLocation.y + newDragLocation.y);
[self setFrameOrigin:thisOrigin];
self.lastDragLocation = newDragLocation;
}
*/