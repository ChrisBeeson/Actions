//
//  TransistionNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class TransitionNodeView: NodeView {
    
    override func drawRect(dirtyRect: NSRect) {

        let frame = self.frame
        let path = NSBezierPath()
        
        drawingContextColours().fill.setFill()
        drawingContextColours().outline.setStroke()
        
        if selected {
            path.lineWidth = 2
            AppConfiguration.Palette.selectionBlue.setStroke()
        } else {
            path.lineWidth = 0.7
        }
        
        path.moveToPoint(NSPoint(x: 0 , y: (frame.size.height/2)-(path.lineWidth/4)))
        path.lineToPoint(NSPoint(x: frame.size.width , y:(frame.size.height/2)-(path.lineWidth/4)))
        path.stroke()
    }
}
