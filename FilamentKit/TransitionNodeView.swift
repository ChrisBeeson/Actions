//
//  TransistionNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class TransitionNodeView: NodeView {
    
    override func calculatePath() -> CGPath {
        
        pathLayer.lineWidth = 1.0
        
        let frame = self.frame
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: 0 , y: (frame.size.height/2)-(path.lineWidth/4)))
        path.lineToPoint(NSPoint(x: frame.size.width , y:(frame.size.height/2)-(path.lineWidth/4)))
        return path.CGPath(forceClose: false)!
    }
}
