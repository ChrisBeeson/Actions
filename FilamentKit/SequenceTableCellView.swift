//
//  SequenceTableRowView.swift
//  Filament
//
//  Created by Chris Beeson on 12/12/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit

public class SequenceTableCellView: NSTableCellView, SequencePresenterDelegate {
    
    public var presenter: SequencePresenter? {
        didSet {
            presenter!.delegate = self
            populateInterface()
        }
    }
    
    
    // UI Properties
    @IBOutlet weak var backgroundView: NSView!
    
    @IBOutlet weak var titleTextField: NSTextField!
    
    @IBAction func titleTextFieldDidChange(sender: NSTextField) {
        
    }
    
    
    func populateInterface() {
        
        backgroundView.backgroundColor = NSColor.whiteColor()
        outline(true)
        
        if presenter != nil {
            titleTextField.stringValue = presenter!.title
        }
    }
    
    public func outline(visible: Bool) {
        
        switch visible {
        case true:
            backgroundView.layer?.borderWidth = 3
            backgroundView.layer?.borderColor = NSColor(red: 0.6, green: 0.75, blue: 0.9, alpha: 1.0).CGColor
            
        case false:
            backgroundView.layer?.borderWidth = 0
        }
    }
    
    
    // MARK: Presenter Delegate
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {
        
        populateInterface()
    }
}

extension NSView {
    var backgroundColor: NSColor? {
        get {
            guard let layer = layer, backgroundColor = layer.backgroundColor else { return nil }
            return NSColor(CGColor: backgroundColor)
        }
        
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.CGColor
        }
    }
}