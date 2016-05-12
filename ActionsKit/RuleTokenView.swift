//
//  RuleTokenView.swift
//  Actions
//
//  Created by Chris on 1/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class RuleTokenView : NSView {
    
    var pathLayer = CAShapeLayer()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false

        pathLayer.path = NSBezierPath(roundedRect: self.bounds, xRadius: 4.0, yRadius: 4.0).CGPath(forceClose: false)
        pathLayer.shouldRasterize = false
        pathLayer.fillColor = AppConfiguration.Palette.tokenBlue.CGColor
        self.wantsLayer = true
        self.layer?.addSublayer(pathLayer)
    }
    
    override func layout() {
        super.layout()
        pathLayer.path =  NSBezierPath(roundedRect: self.bounds, xRadius: 4.0, yRadius: 4.0).CGPath(forceClose: false)
    }
    
    override func viewWillDraw() {
        super.viewWillDraw()
        pathLayer.path =  NSBezierPath(roundedRect: self.bounds, xRadius: 4.0, yRadius: 4.0).CGPath(forceClose: false)
    }
    
    func setColour(colour:CGColorRef) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        pathLayer.fillColor = colour
        CATransaction.commit()
    }
}