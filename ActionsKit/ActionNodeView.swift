//
//  ActionNodeView.swift
//  Actions
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class ActionNodeView: NodeView {
    
    override func calculatePath() -> CGPath {
        
        let tailOff:CGFloat = 15.0
        let fr = self.frame   // CGRectInset(self.frame, 2.0, 2.0)
        let padding:CGFloat = pathLayer.lineWidth
        
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: fr.size.width - tailOff , y: fr.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:fr.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: fr.size.width - tailOff , y:padding))
        path.lineToPoint(NSPoint(x: fr.size.width - (padding / 2), y:fr.size.height/2))   // point
        path.lineToPoint(NSPoint(x: fr.size.width - tailOff , y: fr.size.height - padding))
        return path.CGPath(forceClose: false)!
    }
}