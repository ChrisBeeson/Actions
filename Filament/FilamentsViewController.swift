//
//  FilamentsViewController.swift
//  Filament
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit

public class FilamentsViewController:  NSViewController, NSTableViewDataSource, NSTableViewDelegate,FilamentDocumentsManagerDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    override public func viewDidLoad() {
        
        FilamentDocumentsManager.sharedManager.delegate = self
    }
    
    override public func viewDidAppear() {
        tableView!.reloadData()
    }
    
    // MARK: TableView DataSource
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {

        return FilamentDocumentsManager.sharedManager.documents.count
    }
    
    public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeViewWithIdentifier("SequenceCellView", owner: self) as! SequenceTableCellView
        let docs  = FilamentDocumentsManager.sharedManager.documents
        cellView.presenter = docs[row].sequencePresenter
        return cellView
    }
    
    public func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        
        if tableView.selectedRow == row { return false }
        
        if let cellView = tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? SequenceTableCellView {
            cellView.selected = true
        }
        
        if tableView.selectedRow != -1 {
            if let currentSelection = tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: false)  as? SequenceTableCellView {
                  currentSelection.selected = false
            }
        }
        return true
    }
    
    
    // MARK: Menu events
    
    public func delete(theEvent: NSEvent) {
        
        // ask for conformation of deletion
        
        let alert = NSAlert()
        alert.informativeText = "Are you sure you want to delete this Filament?"
        alert.messageText = "Delete"
        alert.showsHelp = false
        alert.addButtonWithTitle("Delete")
        alert.addButtonWithTitle("Cancel")

        switch (alert.runModal()) {
            
        case NSAlertFirstButtonReturn:   // Delete
            
            if let cellView = tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: false) as? SequenceTableCellView {
                let docToDel = FilamentDocumentsManager.sharedManager.documentForSequence(cellView.presenter!.archiveableSeq)
                FilamentDocumentsManager.permanentlyDeleteDocument(docToDel)
            }
        default: break
        }
    }
    
    // MARK: Filaments Manager Delegate
    
    public func filamentsDocumentsManagerDidUpdateContents(inserted inserted:[SequenceDocument], removed:[SequenceDocument]) {
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            
            self.tableView.reloadData()
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
