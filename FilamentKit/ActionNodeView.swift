//
//  ActionNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class ActionNodeView: NodeView {
    
    var pathLayer : CAShapeLayer
    
    
    required init?(coder: NSCoder) {
        
        pathLayer = CAShapeLayer()
        
        super.init(coder: coder)
        
        pathLayer.lineWidth = 1
        pathLayer.path = calcPath()
        pathLayer.strokeColor = drawingContextColours().outline.CGColor
        pathLayer.fillColor = drawingContextColours().fill.CGColor
        pathLayer.shouldRasterize = false
       
        self.wantsLayer = true
        self.layer?.addSublayer(pathLayer)
    }
    
    
    override func layout() {
        super.layout()
        
        pathLayer.path = calcPath()
    }
    
    
    func calcPath() -> CGPathRef {
        
        let tailOff:CGFloat = 15.0
        let frame = self.frame
        let padding:CGFloat = 1.0
        
        pathLayer.strokeColor = drawingContextColours().outline.CGColor
        pathLayer.fillColor = drawingContextColours().fill.CGColor
        
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - padding , y:frame.size.height/2))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        return path.CGPath(forceClose: false)!
    }
    
    
/*
    override func drawRect(dirtyRect: NSRect) {
   
        let path = NSBezierPath()
        let tailOff:CGFloat = 15.0
        
        let frame = self.frame
        
        drawingContextColours().fill.setFill()
        drawingContextColours().outline.setStroke()
        
        if selected {
            path.lineWidth = 2
            AppConfiguration.Palette.selectionBlue.setStroke()
        } else {
            path.lineWidth = 0.7
        }
        
        let padding = path.lineWidth / 2.0

        path.moveToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - padding , y:frame.size.height/2))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
                
        path.fill()
        path.stroke()
    }
*/

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