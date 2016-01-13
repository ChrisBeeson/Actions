//
//  TransistionNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class TransitionNodeView: NSView {
    
    var text = "Wash Cells"
    var textField:NSTextField?
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override init(frame: NSRect) {
        super.init(frame: NSRect(x: 0.0, y: 0.0, width: 50, height: 40))
        updateView()
    }
    
    
    func updateView() {
        /*
        if textField == nil {
            textField = NSTextField(frame: NSRect(x: 5.0, y: self.frame.height/2 - (20.0/2) , width: self.frame.width * 0.80, height: 20.0))
            textField!.font = NSFont.boldSystemFontOfSize(15.0)
            self.addSubview(textField!)
            textField?.bordered = false
        }
        textField!.stringValue = text
*/
    }
    
    override public func drawRect(dirtyRect: NSRect) {
        
        let frame = self.frame

        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: 0.0 , y: frame.size.height/2))
        path.lineToPoint(NSPoint(x: frame.size.width , y:frame.size.height/2))
        
        NSColor(calibratedWhite:0.6, alpha:1.0).setStroke()
        path.lineWidth = 0.3
        path.lineJoinStyle = .MiterLineJoinStyle
        path.stroke()
    }
}