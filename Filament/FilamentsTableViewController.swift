//
//  FilamentsViewController.swift
//  Filament
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit
import Async

public class FilamentsTableViewController:  NSViewController, NSTableViewDataSource, NSTableViewDelegate, FilamentDocumentsManagerDelegate, RuleCollectionViewDelegate {
    
    @IBOutlet weak var addGenericRuleButton: NSButton!
    @IBOutlet weak var genericRulesCollectionView: RuleCollectionView!
    @IBOutlet weak var tableView: NSTableView!
    
    private var sortedDocuments = [FilamentDocument]()
    private var availableGenericRulesViewController : AvailableRulesViewController?
    
    override public func viewDidLoad() {
        
        FilamentDocumentsManager.sharedManager.delegate = self
        sortedDocuments  = FilamentDocumentsManager.sharedManager.documents
        
        NSNotificationCenter.defaultCenter().addObserverForName("FilamentTableViewSelectCellForView", object: nil, queue: nil) { (notification) -> Void in
            
            let row = self.tableView.rowForView(notification.object as! NSView)
            self.tableView.selectRowIndexes((NSIndexSet(index: row)), byExtendingSelection: false)
        }
        
        genericRulesCollectionView.ruleCollectionViewDelegate = self
        genericRulesCollectionView.allowDrops = true
        genericRulesCollectionView.allowDeletions = true
        
    }
    
    
    override public func viewWillAppear() {

            self.tableView!.reloadData()
            self.tableView.deselectAll(self)
            self.refreshGenericRulesCollectionView()
    }
    
    
    func sortDocuments() {
    }
    
    
    
    // MARK: TableView DataSource
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        //TODO: Presenter to facilitate segmented control selection?
        
        return sortedDocuments.count
    }
    
    public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeViewWithIdentifier("FilamentCellView", owner: self) as! FilamentTableCellView
        cellView.presenter = sortedDocuments[row].sequencePresenter
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
        /*
        DIFF NOT WORKING
        
        let currentDocuments  = sortedDocuments
        
        sortedDocuments.appendContentsOf(inserted)
        sortedDocuments.removeObjects(removed)
        
        let difference = currentDocuments.diff(sortedDocuments)
        
        if difference.results.count > 0 {
        
        difference.insertion.forEach {
        }
        }
        
        if (diff.results.count > 0) {
        let insertedNodes = diff.insertions.map { ($0, $0.idx) }
        let deletedNodes = diff.deletions.map { ($0, $0.idx) }
        
        delegates.forEach { $0.sequencePresenterDidUpdateChainContents(insertedNodes, deletedNodes:deletedNodes) }
        }
        
        updateSequenceStatus()
        */
        Async.main{
            self.tableView.deselectAll(self)
            self.tableView.beginUpdates()
        }
        
        if removed.count > 0 {
            
            let indxs = NSMutableIndexSet()
            
            for doc in removed {
                
                let index = sortedDocuments.indexOf(doc)
                
                if index != -1 { indxs.addIndex(index!) }
                
            }
            Async.main{ [unowned self] in
                self.tableView.removeRowsAtIndexes(indxs, withAnimation: .EffectFade)
            }
            
            sortedDocuments.removeObjects(removed)
        }
        
        if inserted.count > 0 {
            sortedDocuments.appendContentsOf(inserted)
            
            let indxs = NSMutableIndexSet()
            
            for doc in inserted {
                if let index = FilamentDocumentsManager.sharedManager.documents.indexOf(doc) {
                    if index != -1 { indxs.addIndex(index) }
                }
            }
            Async.main{ [unowned self] in
                self.tableView.insertRowsAtIndexes(indxs, withAnimation: .SlideLeft)
            }
        }
        Async.main{
            self.tableView.endUpdates()
        }
    }
    
    
    
    // MARK: First Responder Events
    
    
    public func delete(theEvent: NSEvent) {   // TODO: Muliple
        
        if self.tableView.selectedRowIndexes.count == 0 { return }
        
        let alert = NSAlert()
        alert.informativeText = "TABLEVIEW_DELETE_SEQ_TITLE".localized
        alert.messageText = "TABLEVIEW_DELETE_SEQ_DELETE".localized
        alert.showsHelp = false
        alert.addButtonWithTitle("TABLEVIEW_DELETE_SEQ_DELETE".localized)
        alert.addButtonWithTitle("TABLEVIEW_DELETE_SEQ_CANCEL".localized)
        
        switch (alert.runModal()) {
            
        case NSAlertFirstButtonReturn:   // Delete
            if let cellView = tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: false) as? FilamentTableCellView {
                
                cellView.presenter!.prepareForCompleteDeletion()
                FilamentDocumentsManager.sharedManager.deleteDocumentForPresenter(cellView.presenter!)
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
    
    //MARK: Generic Rules Collection View
    
    @IBAction func addGenericRuleButtonPressed(sender: AnyObject) {
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        if availableGenericRulesViewController == nil {
           availableGenericRulesViewController = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
        }
        availableGenericRulesViewController!.availableRules = AppConfiguration.sharedConfiguration.contextPresenter()   /// A bit of a stretch!!
        availableGenericRulesViewController!.displayRulesForNodeType = [.Generic]
        availableGenericRulesViewController!.collectionViewDelegate = self
        popover.contentViewController = availableGenericRulesViewController
        
        //TODO: Select between preferred Edges..
        popover.showRelativeToRect(addGenericRuleButton.frame, ofView:self.view, preferredEdge:.MaxY )
    }
    
    
    func refreshGenericRulesCollectionView() {
        
        let context = AppConfiguration.sharedConfiguration.contextPresenter()
        genericRulesCollectionView.rulePresenters = context.currentRulePresenters()
        genericRulesCollectionView.reloadData()
        availableGenericRulesViewController?.reloadCollectionView()
    }
    
    
    //MARK: RuleCollectionView Delegates
    
    public func didAcceptDrop(collectionView: RuleCollectionView, droppedRulePresenter: RulePresenter, atIndex: Int) {
        
        AppConfiguration.sharedConfiguration.contextPresenter().addGenericRulePresenter(droppedRulePresenter, atIndex: atIndex)
        refreshGenericRulesCollectionView()
    }
    
    public func didDeleteRulePresenter(collectionView: RuleCollectionView, deletedRulePresenter: RulePresenter) {
        
        AppConfiguration.sharedConfiguration.contextPresenter().removeRulePresenter(deletedRulePresenter)
        refreshGenericRulesCollectionView()
    }
    
    public func didDoubleClick(collectionView: RuleCollectionView, selectedRulePresenter: RulePresenter) {
        
        let context = AppConfiguration.sharedConfiguration.contextPresenter()
        context.addGenericRulePresenter(selectedRulePresenter, atIndex: context.availableRulePresenters().count)
        refreshGenericRulesCollectionView()
    }
    
}

