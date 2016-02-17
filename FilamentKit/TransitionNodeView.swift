//
//  TransistionNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class TransitionNodeView: NSView {
    
    var text = ""
    var textField:NSTextField?
    var selected = false {
    didSet {
    self.setNeedsDisplayInRect(self.frame)
    }
}
    var node:Node?


    required public init?(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override init(frame: NSRect) {
        super.init(frame: NSRect(x: 0.0, y: 0.0, width: 50, height: 40))
        updateView()
    }
    
    convenience init(node:Node) {
        self.init(frame: NSRect(x: 0.0, y: 0.0, width: 100, height: 38))
        self.node = node
    }
    
    
    func updateView() {

    }
    
    override public func drawRect(dirtyRect: NSRect) {
        
        let frame = self.frame
        let path = NSBezierPath()
        
        if selected {
            path.lineWidth = 2
            AppConfiguration.Palette.selectionBlue.setStroke()
            
        } else {
            AppConfiguration.Palette.outlineGray.setStroke()
            path.lineWidth = 0.7
        }

        path.moveToPoint(NSPoint(x: 0 , y: (frame.size.height/2)-(path.lineWidth/4)))
        path.lineToPoint(NSPoint(x: frame.size.width , y:(frame.size.height/2)-(path.lineWidth/4)))
        path.stroke()
    }
}
