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
         fatalError("This class does not support NSCoding")
        //  super.init(coder: coder)!
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    convenience init () {
        self.init(frame:NSRect.zero)
    }
    
    
    public func drawView() {        // date | Action 1 -> Action 2...  simple as that
        
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        var xDrawPosition:CGFloat = 10.0
        
        // date Node
        let dateView = DateNodeView()
        dateView.setFrameOrigin(NSPoint(x: xDrawPosition, y: ((self.frame.size.height/2) - (dateView.frame.size.height/2))))
        self.addSubview(dateView)
        xDrawPosition += dateView.frame.size.width + 5.0
        
        for node in sequence.allNodes() {
            
            switch (node.type) {
                
            case .Action:
                let actionNode = ActionNodeView()
                actionNode.node = node
                actionNode.setFrameOrigin(NSPoint(x: xDrawPosition, y: ((self.frame.size.height/2) - (dateView.frame.size.height/2))))
                self.addSubview(actionNode)
                xDrawPosition += actionNode.frame.size.width
                
            case .Transition:
                let transNode = TransitionNodeView()
                transNode.setFrameOrigin(NSPoint(x: xDrawPosition, y: ((self.frame.size.height/2) - (dateView.frame.size.height/2))))
                self.addSubview(transNode)
                xDrawPosition += transNode.frame.size.width
                
            default:
                break
            }
        }
        
        /*
        
        let scrollView = self.superview?.superview?.superview as! NSScrollView
        
        if scrollView.className == "NSScrollView" {
            //   let sv = scrollView! as! NSScrollView
            let size = NSSize(width: 5000, height: scrollView.frame.size.height)
            scrollView.documentView!.setFrameSize(size)
            // scrollView.contentView.setFrameSize(size)
            
            Swift.print(scrollView.contentView)
            
        } else {
            Swift.print("Unable to find sequence View scrollView")
        }
        
           Swift.print(NSStringFromRect(self.frame))
*/
        
        
     
        
        //self.translatesAutoresizingMaskIntoConstraints = false
        
        //    self.frame = NSRect(x: 0.0, y: self.frame.size.height, width: xDrawPosition, height: self.frame.size.height)
    }
}