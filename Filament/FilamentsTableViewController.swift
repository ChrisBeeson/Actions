//
//  FilamentsViewController.swift
//  Filament
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit

public class FilamentsTableViewController:  NSViewController, NSTableViewDataSource, NSTableViewDelegate, FilamentDocumentsManagerDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    override public func viewDidLoad() {
        
        FilamentDocumentsManager.sharedManager.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserverForName("FilamentTableViewSelectCellForView", object: nil, queue: nil) { (notification) -> Void in
            
            let row = self.tableView.rowForView(notification.object as! NSView)
            self.tableView.selectRowIndexes((NSIndexSet(index: row)), byExtendingSelection: false)
        }
    }
    
    override public func viewWillAppear() {
        
        tableView!.reloadData()
        tableView.deselectAll(self)
    }
    
    
    
    // MARK: TableView DataSource
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        //TODO: Presenter to facilitate segmented control selection?
        
        return FilamentDocumentsManager.sharedManager.documents.count
    }
    
    public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeViewWithIdentifier("FilamentCellView", owner: self) as! FilamentTableCellView
        let docs  = FilamentDocumentsManager.sharedManager.documents
        cellView.presenter = docs[row].sequencePresenter
        return cellView
    }
    
    public func tableViewSelectionDidChange(notification: NSNotification) {
        
        for (var row = 0; row < tableView.numberOfRows ; row++)
        {
            if let cellView = tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? FilamentTableCellView {
                cellView.selected = tableView.isRowSelected(row)
            }
        }
    }
    
    
    
    
    // MARK: Filaments Manager Delegate
    
    
    public func filamentsDocumentsManagerDidUpdateContents(inserted inserted:[FilamentDocument], removed:[FilamentDocument]) {
        
        //TODO: UI - animate inserts & deletions
        
        // tableView.removeRowsAtIndexes(<#T##indexes: NSIndexSet##NSIndexSet#>, withAnimation: <#T##NSTableViewAnimationOptions#>)
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            
            self.tableView.reloadData()
        }
    }

    

    // MARK: First Responder Events

    
    public func delete(theEvent: NSEvent) {   // TODO: Muliple
        
        if self.tableView.selectedRowIndexes.count == 0 { return }
        
        let alert = NSAlert()
        alert.informativeText = "Are you sure you want to delete this Filament?"
        alert.messageText = "Delete"
        alert.showsHelp = false
        alert.addButtonWithTitle("Delete")
        alert.addButtonWithTitle("Cancel")
        
        switch (alert.runModal()) {
            
        case NSAlertFirstButtonReturn:   // Delete
            if let cellView = tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: false) as? FilamentTableCellView {
                let docToDel = FilamentDocumentsManager.sharedManager.documentForSequence(cellView.presenter!.archiveableSeq)
                cellView.presenter = nil
                FilamentDocumentsManager.permanentlyDeleteDocument(docToDel)
                cellView.presenter = nil
            }
        default: break
        }
    }
    
    /*
    override public func keyDown(theEvent: NSEvent) {
    Swift.print(theEvent)
    }
    */
    
    public func cut(event: NSEvent) {
        Swift.print(event)
    }
    
    public func undo(event: NSEvent) {
        self.undoManager?.undo()
    }
    
    
    public override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        // deselect if click wasn't on a row
        let point = tableView.convertPoint(theEvent.locationInWindow, fromView: nil)
        let row = tableView.rowAtPoint(point)
        if row == -1 {
            tableView.deselectAll(nil)
        }
    }
    
    
}
