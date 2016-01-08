//
//  SequenceView.swift
//  Filament
//
//  Created by Chris Beeson on 2/12/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class SequenceView : NSView {
    
    public var sequence : Sequence! {
        didSet {
            drawView()
        }
    }
    
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)!
        
        drawView()
    }
    
    
    public func drawView() {        // date | Action 1 -> Action 2...  simple as that
        
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        // date Node
        let dateView = DateNodeView()
        dateView.setFrameOrigin(NSPoint(x: 0.0, y: ((self.frame.size.height/2) - (dateView.frame.size.height/2))))
        self.addSubview(dateView)
    }
}