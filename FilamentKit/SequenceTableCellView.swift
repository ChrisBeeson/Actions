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
    
    // UI Properties
    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var titleTextField: NSTextField!

    public var presenter: SequencePresenter? {
        didSet {
            presenter!.delegate = self
            updateCellView()
        }
    }
    
    public var selected: Bool {
        didSet {
            updateCellView()
    }
}
    
    // MARK: Methods
    
    required public init?(coder: NSCoder) {
        selected = false
        super.init(coder: coder)
    }
    

    func updateCellView() {
        
        backgroundView.backgroundColor = NSColor.whiteColor()

        if presenter != nil {
            titleTextField.stringValue = presenter!.title
        }
        
        switch selected {
        case true:
            backgroundView.layer?.borderWidth = 3
            backgroundView.layer?.borderColor = NSColor(red: 0.6, green: 0.75, blue: 0.9, alpha: 1.0).CGColor
            titleTextField.editable = true
            
        case false:
            backgroundView.layer?.borderWidth = 0
            titleTextField.editable = false
        }
    }
    
    
    @IBAction func titleTextFieldDidChange(sender: NSTextField) {
        
    }
    

    // MARK: Presenter Delegate
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {
        
        updateCellView()
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