//
//  ActionNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class ActionNodeView: NodeView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        pathLayer.lineWidth = 0.5
        pathLayer.path = calcPath()
        pathLayer.shouldRasterize = false
        pathLayer.strokeColor = drawingContextColour(.LightGrey).stroke
        pathLayer.fillColor = drawingContextColour(.LightGrey).fill
       
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
        
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - padding , y:frame.size.height/2))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        return path.CGPath(forceClose: false)!
    }
    
}

/*
    override func drawRect(dirtyRect: NSRect) {
   
        let path = NSBezierPath()
        let tailOff:CGFloat = 15.0
        
        let frame = self.frame
        
        drawingContextColours().fill.setFill()
        drawingContextColours().stroke.setStroke()
        
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