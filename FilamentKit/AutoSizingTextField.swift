//
//  AutoSizingTextField.swift
//  Filament
//
//  Created by Chris Beeson on 8/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class AutoSizingTextField : NSTextField {
    
    var hasLastIntrinsicSize =  false
    var isEditing = false
    var lastIntrinsicSize = NSSize.zero
    
    override func textDidBeginEditing(notification: NSNotification) {
        super.textDidBeginEditing(notification)
        isEditing = true
    }
    
    override func textDidEndEditing(notification: NSNotification) {
        super.textDidEndEditing(notification)
        isEditing = false
    }
    
    override func textDidChange(notification: NSNotification) {
        super.textDidChange(notification)
        invalidateIntrinsicContentSize()
    }
    
    
    override var intrinsicContentSize : NSSize {
        
        var intrinsicSize = lastIntrinsicSize
        
        if isEditing || !hasLastIntrinsicSize {
            
            let fieldEditor = window!.fieldEditor(false, forObject: self)
            
            if fieldEditor != nil && fieldEditor!.isKindOfClass(NSTextView) {
                
                let textView = fieldEditor as! NSTextView
                let usedRect = textView.textContainer?.layoutManager?.usedRectForTextContainer(textView.textContainer!)
                intrinsicSize.height = usedRect!.size.height + 5.0
            }
            hasLastIntrinsicSize = true
            lastIntrinsicSize = intrinsicSize
        } else {
            
        }
        
        return intrinsicSize
    }
}
