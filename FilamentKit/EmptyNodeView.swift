//
//  EmptyNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 15/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class EmptyNodeView: NSView {


    override public func drawRect(dirtyRect: NSRect) {
        
        //  self.layer?.masksToBounds
        //  self.layer?.backgroundColor =  AppConfiguration.Palette.outlineGray
        
        let path = NSBezierPath(ovalInRect: self.bounds)
        
        AppConfiguration.Palette.filledGray.setFill()
        
        AppConfiguration.Palette.outlineGray.setStroke()
        path.lineWidth = 0.7
        
        path.fill()
        path.stroke()
        
        
        /*
        
        let frame = self.frame
        let path = NSBezierPath()
        
        if selected {
            path.lineWidth = 2
            AppConfiguration.Palette.selectionBlue.setStroke()
            
        } else {
            AppConfiguration.Palette.outlineGray.setStroke()
            path.lineWidth = 0.7
        }
        
        path.moveToPoint(NSPoint(x: 0 , y: (frame.size.height/2)-(path.lineWidth/2)))
        path.lineToPoint(NSPoint(x: frame.size.width , y:(frame.size.height/2)-(path.lineWidth/2)))
        path.stroke()
        
        */
    
    }
}

