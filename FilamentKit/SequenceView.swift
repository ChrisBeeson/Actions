//
//  SequenceView.swift
//  Filament
//
//  Created by Chris Beeson on 2/12/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class SequenceView : NSView {
    
    public var sequence : Sequence! {   /// should change this to presenter
        didSet {
            drawView()
        }
    }
    
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)!
        
        //     drawView()
    }
    
    
    public func drawView() {        // date | Action 1 -> Action 2...  simple as that
        
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        var xDrawPosition:CGFloat = 10.0
        
        // date Node
        let dateView = DateNodeView()
        dateView.setFrameOrigin(NSPoint(x: xDrawPosition, y: ((self.frame.size.height/2) - (dateView.frame.size.height/2))))
        self.addSubview(dateView)
        
        xDrawPosition += dateView.frame.size.width
        
        for node in sequence.allNodes() {
            switch (node.type) {
                
            case .Action:
                let actionNode = ActionNodeView()
                actionNode.setFrameOrigin(NSPoint(x: xDrawPosition, y: ((self.frame.size.height/2) - (dateView.frame.size.height/2))))
                self.addSubview(actionNode)
                xDrawPosition += actionNode.frame.size.width
                break
                
            case .Transition:
                let transNode = TransitionNodeView()
                transNode.setFrameOrigin(NSPoint(x: xDrawPosition, y: ((self.frame.size.height/2) - (dateView.frame.size.height/2))))
                self.addSubview(transNode)
                xDrawPosition += transNode.frame.size.width
                
                break
            default:
                break
                
            }
        }
        
    }
}