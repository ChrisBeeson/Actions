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

        pathLayer.path = NSBezierPath(roundedRect: self.bounds, xRadius: 5.0, yRadius: 5.0).CGPath(forceClose: false)
        pathLayer.shouldRasterize = false
        pathLayer.fillColor = AppConfiguration.Palette.tokenBlue.CGColor
        self.wantsLayer = true
        self.layer?.addSublayer(pathLayer)
    }
} 