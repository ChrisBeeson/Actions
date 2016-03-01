//
//  RulePillView.swift
//  Filament
//
//  Created by Chris on 1/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class RulePillView : NSView {
    
    var pathLayer: CAShapeLayer
    
    required init?(coder: NSCoder) {
        
         pathLayer = CAShapeLayer()
        
        super.init(coder: coder)
        /*
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        self.layer?.backgroundColor = AppConfiguration.Palette.redFill.CGColor
        self.layer?.cornerRadius = 8.0
*/
        
        
        // pathLayer.lineWidth = 1.0
        pathLayer.path = NSBezierPath(roundedRect: self.bounds, xRadius: 4.0, yRadius: 4.0).CGPath(forceClose: false)
        pathLayer.shouldRasterize = false
        //pathLayer.strokeColor = drawingContextColour(.LightGrey).stroke
        pathLayer.fillColor = AppConfiguration.Palette.tokenBlue.CGColor
        
        self.wantsLayer = true
        self.layer?.addSublayer(pathLayer)
        
        
        /*
        
        NSBezierPath * path;
        path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:10 yRadius:10];
        [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.3] set];
        [path fill];

*/
        
    }
    
} 