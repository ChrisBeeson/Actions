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
    var selected = false {
        didSet {
            self.setNeedsDisplayInRect(self.frame)
        }
    }
    
    public var node : Node? {
        didSet {
            self.setNeedsDisplayInRect(self.frame)
        }
    }
    
    override public func drawRect(dirtyRect: NSRect) {
        
        let tailOff:CGFloat = 15.0
        let padding:CGFloat = 2
        let frame = self.frame
        
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width-1 , y:frame.size.height/2))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        
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