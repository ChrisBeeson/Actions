//
//  FilamentsViewController.swift
//  Filament
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit

class FilamentsViewController:  NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var documents: [SequenceDocument]?
    
    
    override func viewDidLoad() {
        populateDocuments()
    }
    
    override func viewDidAppear() {
        tableView!.reloadData()
    }
    
    func populateDocuments() {
        documents = SequenceDocumentsManager.sharedManager.documents()
        print(documents)
    }
    
    // MARK: TableView DataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let docs = documents {
            return docs.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeViewWithIdentifier("SequenceCellView", owner: self) as! SequenceTableCellView
        cellView.presenter = documents![row].sequencePresenter
        
        return cellView
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        
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
}
