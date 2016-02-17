//
//  ActionNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class ActionNodeView: NodeView {
    

    override func drawRect(dirtyRect: NSRect) {
        
        let path = NSBezierPath()
        let tailOff:CGFloat = 15.0
        
        let frame = self.frame
        
        if selected {
            path.lineWidth = 2
            AppConfiguration.Palette.selectionBlue.setStroke()
        } else {
            path.lineWidth = 0.7
            AppConfiguration.Palette.outlineGray.setStroke()
            // NSColor(calibratedRed: 1.0, green: 0.1, blue: 0.1, alpha: 1.0).setStroke()
            //  NSColor(calibratedRed: 0.1, green: 0.8, blue: 0.1, alpha: 1.0).setStroke()
            NSColor(calibratedRed: 0.1, green: 0.1, blue: 1.0, alpha: 1.0).setStroke()
        }
        
        let padding = path.lineWidth / 2.0

        path.moveToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - padding , y:frame.size.height/2))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        
        AppConfiguration.Palette.filledGray.setFill()
        
        //  NSColor(calibratedRed: 1.0, green: 0.1, blue: 0.1, alpha: 0.08).setFill()
        //  NSColor(calibratedRed: 0.1, green: 0.8, blue: 0.1, alpha: 0.08).setFill()
         NSColor(calibratedRed: 0.1, green: 0.1, blue: 1.0, alpha: 0.08).setFill()
        path.fill()
        path.stroke()
    }
    
    
    
    

}