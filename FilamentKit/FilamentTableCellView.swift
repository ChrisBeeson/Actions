//
//  SequenceTableRowView.swift
//  Filament
//
//  Created by Chris Beeson on 12/12/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit

public class FilamentTableCellView: NSTableCellView, SequencePresenterDelegate {
    
    override public var acceptsFirstResponder: Bool { return true }
    
    // UI Properties
    @IBOutlet weak var backgroundView: NSView!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var collectionView: SequenceCollectionView!
    @IBOutlet weak var scrollview: NSScrollView!
    
    public var presenter: SequencePresenter? {
        
        didSet {
            collectionView.presenter = presenter
            if presenter != nil {
                presenter!.addDelegate(self)
            }
            updateCellView()
        }
    }
    
    public var selected: Bool {
        didSet {
            switch selected {
            case true:
                backgroundView.layer?.borderWidth = 2
                backgroundView.layer?.borderColor = AppConfiguration.Palette.selectionBlue.CGColor
                titleTextField.editable = true
                
            case false:
                backgroundView.layer?.borderWidth = 0
                titleTextField.editable = false
                collectionView.deselectAll(self)
            }
        }
    }
    
    
    // MARK: Methods
    
    required public init?(coder: NSCoder) {
        
        selected = false
        super.init(coder: coder)
    }
    
    
    func updateCellView() {
        
        scrollview.horizontalScroller?.alphaValue = 0.0
        backgroundView.backgroundColor = NSColor.whiteColor()
        
        if presenter != nil {
            
            titleTextField.stringValue = presenter!.title
            self.collectionView.toolTip = String(presenter!.status)
            collectionView.reloadData()
        }
    }
    
    
    @IBAction func titleTextFieldDidChange(sender: NSTextField) {
        
        presenter!.renameTitle(sender.stringValue)
    }

    

    
    // MARK: Presenter Delegate
    
    public func sequencePresenterDidRefreshCompleteLayout(sequencePresenter: SequencePresenter) {
        updateCellView()
    }
    
    
    public func sequencePresenterDidChangeStatus(sequencePresenter: SequencePresenter, toStatus:SequenceStatus){
        
         self.collectionView.toolTip = String(presenter!.status)
    }
    
    /*
    
    Context Menu
    
    -(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    CGPoint p = [gestureRecognizer locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath != nil) {
    
    [self becomeFirstResponder];
    UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(customDelete:)];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObjects:delete, nil]];
    [menu setTargetRect:[self.tableView rectForRowAtIndexPath:indexPath] inView:self.tableView];
    [menu setMenuVisible:YES animated:YES];
    }
    }
    }
    
    - (void)customDelete:(id)sender {
    //
    }
    */
    
    
    /*
    public func performClose(sender: AnyObject) {
    Swift.print("Export")
    }
    
    public override func keyDown(theEvent: NSEvent) {
    Swift.print(theEvent)
    }
    */
    
    /*
    public override func mouseUp(theEvent: NSEvent) {
        
        Swift.print(self.window!.firstResponder)
        self.nextResponder?.mouseDown(theEvent)
        
        // TODO: Context menu please
        
    }
*/
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