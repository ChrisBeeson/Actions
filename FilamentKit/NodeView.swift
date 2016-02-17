//
//  NodeView.swift
//  Filament
//
//  Created by Chris on 17/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class NodeView: NSView {
    
    var selected = false {
        didSet {
            self.setNeedsDisplayInRect(self.frame)
        }
    }
    
    var node : Node? {
        didSet {
            self.setNeedsDisplayInRect(self.frame)
        }
    }

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