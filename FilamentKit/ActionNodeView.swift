//
//  ActionNodeView.swift
//  Filament
//
//  Created by Chris Beeson on 9/01/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class ActionNodeView: NSView {
    
    var textField : NSTextField?
    var selected = true {
        didSet {
            self.setNeedsDisplayInRect(self.frame)
        }
    }
    
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
            textField!.font = NSFont.systemFontOfSize(14.0)
            // textField!.font = NSFont.systemFontOfSize(14.0, weight: 1.0)
            textField!.backgroundColor = NSColor.clearColor()
            textField?.selectable = false
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
        let padding:CGFloat = 2
        let frame = self.frame
        
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: frame.size.width * tailOff , y: frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width * tailOff , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width-1 , y:frame.size.height/2))
        path.lineToPoint(NSPoint(x: frame.size.width * tailOff , y: frame.size.height - padding))
        
        if selected {
            path.lineWidth = 1.5
            AppConfiguration.Palette.selectionBlue.setStroke()
        } else {
            path.lineWidth = 0.5
             AppConfiguration.Palette.outlineGray.setStroke()
        }
        
        AppConfiguration.Palette.filledGray.setFill()

        path.fill()
        path.stroke()
    }
    
    /*
    
    // -------------------- MOUSE EVENTS ------------------- \\
    
    - (BOOL) acceptsFirstMouse:(NSEvent *)e {
    return YES;
    }
    
    - (void)mouseDown:(NSEvent *) e {
    
    // Convert to superview's coordinate space
    self.lastDragLocation = [[self superview] convertPoint:[e locationInWindow] fromView:nil];
    
    }
    
    - (void)mouseDragged:(NSEvent *)theEvent {
    
    // We're working only in the superview's coordinate space, so we always convert.
    NSPoint newDragLocation = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint thisOrigin = [self frame].origin;
    thisOrigin.x += (-self.lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-self.lastDragLocation.y + newDragLocation.y);
    [self setFrameOrigin:thisOrigin];
    self.lastDragLocation = newDragLocation;
    }
    */
}