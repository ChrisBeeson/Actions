//
//  FilamentsViewController.swift
//  Filament
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit

public class FilamentsViewController:  NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var documents: [SequenceDocument]?
    
    
    override public func viewDidLoad() {
        populateDocuments()
    }
    
    override public func viewDidAppear() {
        tableView!.reloadData()
    }
    
    func populateDocuments() {
        documents = SequenceDocumentsManager.sharedManager.documents()
        print(documents)
    }
    
    // MARK: TableView DataSource
    
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let docs = documents {
            return docs.count
        } else {
            return 0
        }
    }
    
    public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeViewWithIdentifier("SequenceCellView", owner: self) as! SequenceTableCellView
        cellView.presenter = documents![row].sequencePresenter
        
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
    
    
    /// MARK: Menu events
    
    public func delete(theEvent: NSEvent) {
        
        let alert = NSAlert()
        alert.informativeText = "Are you sure you want to delete this Filament?"
        alert.messageText = "Delete"
        alert.showsHelp = false
        alert.addButtonWithTitle("Delete")
        alert.addButtonWithTitle("Cancel")
        let response = alert.runModal()
        
        switch (response) {
        case NSAlertFirstButtonReturn:
            // find presenter for selected row
            
            if let cellView = tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: false) as? SequenceTableCellView {
                
                // SequenceDocumentsManager.sharedManager.deleteDocumentForSequence(cellView.sequence)
            }
            
            // delete.
            
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
    
}
