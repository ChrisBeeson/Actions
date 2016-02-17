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
        
        let path = NSBezierPath()
        let tailOff:CGFloat = 15.0
        
        let frame = self.frame
        
        if selected {
            path.lineWidth = 2
            AppConfiguration.Palette.selectionBlue.setStroke()
        } else {
            path.lineWidth = 0.7
            AppConfiguration.Palette.outlineGray.setStroke()
            // NSColor(calibratedRed: 1.0, green: 0.1, blue: 0.1, alpha: 1.0).setStroke()
            //  NSColor(calibratedRed: 0.1, green: 0.8, blue: 0.1, alpha: 1.0).setStroke()
            NSColor(calibratedRed: 0.1, green: 0.1, blue: 1.0, alpha: 1.0).setStroke()
        }
        
        let padding = path.lineWidth / 2.0

        path.moveToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:frame.size.height - padding))
        path.lineToPoint(NSPoint(x: padding , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y:padding))
        path.lineToPoint(NSPoint(x: frame.size.width - padding , y:frame.size.height/2))
        path.lineToPoint(NSPoint(x: frame.size.width - tailOff , y: frame.size.height - padding))
        
        AppConfiguration.Palette.filledGray.setFill()
        
        //  NSColor(calibratedRed: 1.0, green: 0.1, blue: 0.1, alpha: 0.08).setFill()
        //  NSColor(calibratedRed: 0.1, green: 0.8, blue: 0.1, alpha: 0.08).setFill()
         NSColor(calibratedRed: 0.1, green: 0.1, blue: 1.0, alpha: 0.08).setFill()
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