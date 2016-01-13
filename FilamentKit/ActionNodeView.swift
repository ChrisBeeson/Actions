//
//  ActionNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class ActionNodeView: NSView {
    
    var textField:NSTextField?
    
    public var node : Node? {
        didSet {
            updateView()
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override init(frame: NSRect) {
        super.init(frame: NSRect(x: 0.0, y: 0.0, width: 100, height: 38))
        updateView()
    }
    
    
    func updateView() {
        
        if textField == nil {
            textField = NSTextField(frame: NSRect(x: 10.0, y: self.frame.height/2 - (20.0/2) , width: self.frame.width * 0.80, height: 20.0))
            textField!.font = NSFont.systemFontOfSize(15.0)
            textField!.backgroundColor = NSColor.clearColor()
            self.addSubview(textField!)
            textField?.bordered = false
        }
        
        if node != nil {
            textField!.stringValue = node!.title
            
            var xDrawPosition:CGFloat = 0.0
            
            for rule in node!.rules {
                
                let button = NSButton(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 45.0, height: 10.0)))
                button.font = NSFont.systemFontOfSize(8.0)
                button.title = rule.name
                button.bezelStyle = .InlineBezelStyle
                button.setFrameOrigin(NSPoint(x: xDrawPosition, y: self.frame.size.height-15))
                //  self.addSubview(button)
                
                xDrawPosition += button.frame.size.width
            }
        }
    }
    
    override public func drawRect(dirtyRect: NSRect) {
        
        let tailOff:CGFloat = 0.85   // 85% of the view consists of the tailing triangle
        let padding:CGFloat = 2.0
        let frame = self.frame
        
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: frame.size.width * tailOff , y: frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width * tailOff , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width , y:frame.size.height/2))
        path.lineToPoint(NSPoint(x: frame.size.width * tailOff , y: frame.size.height - padding))
        
        NSColor(calibratedWhite:0.7, alpha:1.0).setStroke()
        NSColor(calibratedWhite:0.9, alpha:1.0).setFill()

        path.lineWidth = 0.1
        path.fill()
        path.stroke()
    }
}