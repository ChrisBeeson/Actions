//
//  ActionNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class ActionNodeView: NodeView {
    
    override func calculatePath() -> CGPath {
        
        let tailOff:CGFloat = 15.0
        let frame = self.frame
        let padding:CGFloat = 0.5
        
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - padding, y:frame.size.height/2))   // point
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        return path.CGPath(forceClose: false)!
    }
}