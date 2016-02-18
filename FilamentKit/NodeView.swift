//
//  NodeView.swift
//  Filament
//
//  Created by Chris on 17/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

enum DrawColour: Int { case LightGrey, Green, Red, Blue}

class NodeView: NSView {
    
    var pathLayer : CAShapeLayer
    
    
    required init?(coder: NSCoder) {
        
        pathLayer = CAShapeLayer()
        super.init(coder: coder)
    }
    
    
    var selected = false {
        didSet {
            self.setNeedsDisplayInRect(self.frame)
        }
    }
    
    var currentColour = DrawColour.LightGrey {
        didSet {
            self.setNeedsDisplayInRect(self.frame)
        }
    }
    
    func drawingContextColours() -> (fill:NSColor, outline:NSColor) {
 
        switch currentColour {
        case .LightGrey:
            return (AppConfiguration.Palette.lightGreyFill, AppConfiguration.Palette.lightGreyOutline)
        case .Green:
            return (AppConfiguration.Palette.greenFill, AppConfiguration.Palette.greenOutline)
        case .Red:
            return (AppConfiguration.Palette.redFill, AppConfiguration.Palette.redOutline)
        case .Blue:
            return (AppConfiguration.Palette.blueFill, AppConfiguration.Palette.blueOutline)
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