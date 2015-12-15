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
    
    override public var acceptsFirstResponder: Bool { return true }
    
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
            //  self.becomeFirstResponder()
            
        case false:
            backgroundView.layer?.borderWidth = 0
            titleTextField.editable = false
            //self.resignFirstResponder()
        }
    }
    
    
    @IBAction func titleTextFieldDidChange(sender: NSTextField) {
        presenter!.renameTitle(sender.stringValue)
    }
    

    // MARK: Presenter Delegate
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {
        updateCellView()
    }
    
    /*
    public func performClose(sender: AnyObject) {
        Swift.print("Export")
    }
    
    public override func keyDown(theEvent: NSEvent) {
        Swift.print(theEvent)
    }
    */

    public override func mouseUp(theEvent: NSEvent) {
        
        Swift.print(self.window!.firstResponder)
        self.nextResponder?.mouseDown(theEvent)
        
        // TODO: Context menu please
        
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