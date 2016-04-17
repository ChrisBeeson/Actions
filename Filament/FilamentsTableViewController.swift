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

public class FilamentsTableViewController:  NSViewController, NSTableViewDataSource, NSTableViewDelegate, FilamentDocumentsManagerDelegate, RuleCollectionViewDelegate, NSPopoverDelegate {
    
    @IBOutlet weak var addGenericRuleButton: NSButton!
    @IBOutlet weak var genericRulesCollectionView: RuleCollectionView!
    @IBOutlet weak var tableView: NSTableView!
    
    private var allDocuments = [FilamentDocument]()
    private var filteredDocuments = [FilamentDocument]()
    private var filter = DocumentFilterType.Active
    private var availableGenericRulesViewController : AvailableRulesViewController?
    private var displayedPopover:NSPopover?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        FilamentDocumentsManager.sharedManager.delegate = self
        allDocuments  = FilamentDocumentsManager.sharedManager.documents
        
        genericRulesCollectionView.ruleCollectionViewDelegate = self
        genericRulesCollectionView.allowDrops = true
        genericRulesCollectionView.allowDropsFromType = [.Generic]
        genericRulesCollectionView.allowDeletions = true
        
        NSNotificationCenter.defaultCenter().addObserverForName("FilamentTableViewSelectCellForView", object: nil, queue: nil) { (notification) -> Void in
            let row = self.tableView.rowForView(notification.object as! NSView)
            self.tableView.selectRowIndexes((NSIndexSet(index: row)), byExtendingSelection: false)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("RefreshMainTableView", object: nil, queue: nil) { (notification) -> Void in
            self.updateTableViewContent(true)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        
        updateTableViewContent(false)
        refreshGenericRulesCollectionView()
    }
    
    
    func setTableViewFilter(filter: DocumentFilterType) {
        if self.filter != filter {
            self.filter = filter
            updateTableViewContent(false)
        }
    }
    
    func updateTableViewContent(animated:Bool) {
        let newFilteredDocuments = FilamentDocumentsManager.filterDocumentsForFilterType(allDocuments, filterType: self.filter)
        
        if animated == false {
            filteredDocuments = newFilteredDocuments
            CATransaction.begin() ; CATransaction.setDisableActions(true)
            self.tableView!.reloadData()
            self.tableView.deselectAll(self)
            CATransaction.commit()
            return
        }
        
        let oldRows = filteredDocuments
        let newRows = newFilteredDocuments
        let diff = oldRows.diff(newRows)
        filteredDocuments = newFilteredDocuments
        
        if (diff.results.count > 0) {
            let deletionIndexPaths = NSMutableIndexSet()
            diff.deletions.forEach { deletionIndexPaths.addIndex($0.idx) }
            let insertionIndexPaths = NSMutableIndexSet()
            diff.insertions.forEach { insertionIndexPaths.addIndex($0.idx) }
            
            self.tableView?.beginUpdates()
            self.tableView?.removeRowsAtIndexes(deletionIndexPaths, withAnimation: NSTableViewAnimationOptions.EffectFade)
            self.tableView?.insertRowsAtIndexes(insertionIndexPaths, withAnimation: NSTableViewAnimationOptions.SlideLeft)
            self.tableView?.endUpdates()
        }
    }
    
    
    // MARK: TableView DataSource
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return filteredDocuments.count
    }
    
    public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeViewWithIdentifier("FilamentCellView", owner: self) as! FilamentTableCellView
        cellView.presenter = filteredDocuments[row].sequencePresenter
        cellView.presenter?.addDelegate(cellView)
        cellView.presenter?.undoManager = self.undoManager
        cellView.presenter?.updateState(true)
        cellView.updateCellView()
        return cellView
    }
    
    public func tableViewSelectionDidChange(notification: NSNotification) {
        
        for row in 0 ..< tableView.numberOfRows {
            if let cellView = tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? FilamentTableCellView {
                cellView.selected = tableView.isRowSelected(row)
            }
        }
    }
    
    // MARK: Filaments Manager Delegate
    
    public func filamentsDocumentsManagerDidUpdateContents(inserted inserted:[FilamentDocument], removed:[FilamentDocument]) {
            self.allDocuments.removeObjects(removed)
            self.allDocuments.appendContentsOf(inserted)
            self.updateTableViewContent(true)
    }
    
    // MARK: First Responder Events
    
    public func delete(theEvent: NSEvent) {
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
                Async.userInitiated {
                    FilamentDocumentsManager.sharedManager.deleteDocumentForPresenter(cellView.presenter!)
                    cellView.presenter = nil
                }
            }
        default: break
        }
    }
    
    /*
     override public func keyDown(theEvent: NSEvent) {
     Swift.print(theEvent)
     }
     */
    
    public func newDocument(event: NSEvent) {
        FilamentDocument.newDocument("NEW_DOCUMENT_DEFAULT_TITLE".localized)
    }
    
    public func openDocument(event: NSEvent) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        //    panel.allowedFileTypes = [".fil"]
        panel.beginWithCompletionHandler { (result) in
            
            if result == NSFileHandlingPanelOKButton && panel.URL != nil {
                FilamentDocument.newDocumentFromJSON(panel.URL!)
            }
        }
    }
    
    public func saveDocumentAs(event: NSEvent) {
        guard let sequence = filteredDocuments[self.tableView.selectedRow].sequencePresenter else { return }
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = sequence.representingDocument!.suggestedExportFilename
        
        self.tableView.window!
        
        panel.beginSheetModalForWindow(self.tableView.window!, completionHandler:{ (result) in
            if result == NSFileHandlingPanelOKButton && panel.URL != nil {
                sequence.representingDocument!.exportWithFilename(panel.URL!)
            }
        })
    }
    
    public func copy(event: NSEvent) {
        guard self.tableView.selectedRow != -1 else { return }
        
        let pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.clearContents()
        
        if let sequence = filteredDocuments[self.tableView.selectedRow].sequencePresenter {
            let item = sequence.pasteboardItem()
            pasteboard.writeObjects([item])
        }
    }
    
    public func paste(event: NSEvent) {
        let pasteboard = NSPasteboard.generalPasteboard()
        if let data = pasteboard.dataForType(AppConfiguration.UTI.container) {
            FilamentDocument.newDocumentFromArchive(data)
        }
    }
    
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
    
    
    //MARK: Menu
    public override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        
        switch menuItem.action {
        case #selector(FilamentsTableViewController.newDocument(_:)):
            return true
            
        case #selector(FilamentsTableViewController.openDocument(_:)):
            return true
            
        case #selector(FilamentsTableViewController.paste(_:)):
            let pasteboard = NSPasteboard.generalPasteboard()
            return pasteboard.canReadItemWithDataConformingToTypes([AppConfiguration.UTI.container])
            
        case #selector(FilamentsTableViewController.copy(_:)),
             #selector(FilamentsTableViewController.cut(_:)),
             #selector(FilamentsTableViewController.delete(_:)),
             #selector(FilamentsTableViewController.saveDocumentAs(_:)):
            return self.tableView.selectedRowIndexes.count > 0 ? true : false
            
        case #selector(FilamentsTableViewController.undo(_:)):
            return self.undoManager!.canUndo
            
        default: return false
        }
    }
    
    //MARK: Generic Rules Collection View
    
    @IBAction func addGenericRuleButtonPressed(sender: AnyObject) {
        if displayedPopover != nil {return }
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.delegate = self
        
        if availableGenericRulesViewController == nil {
            availableGenericRulesViewController = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.FilamentKit"))
        }
        availableGenericRulesViewController!.availableRules = AppConfiguration.sharedConfiguration.contextPresenter()
        availableGenericRulesViewController!.displayRulesForNodeType = [.Generic]
        availableGenericRulesViewController!.collectionViewDelegate = self
        popover.contentViewController = availableGenericRulesViewController
        popover.showRelativeToRect(addGenericRuleButton.frame, ofView:self.view.superview!, preferredEdge:.MaxY )
    }
    
    
    func refreshGenericRulesCollectionView() {
        let context = AppConfiguration.sharedConfiguration.contextPresenter()
        genericRulesCollectionView.rulePresenters = context.currentRulePresenters()
        genericRulesCollectionView.reloadData()
        availableGenericRulesViewController?.reloadCollectionView()
    }
    
    
    //MARK: RuleCollectionView Delegates
    
    public func didAcceptDrop(collectionView: RuleCollectionView, droppedRulePresenter: RulePresenter, atIndex: Int) {
        AppConfiguration.sharedConfiguration.contextPresenter().addRulePresenter(droppedRulePresenter, atIndex: atIndex)
        refreshGenericRulesCollectionView()
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateAllSequences", object: nil)
    }
    
    public func didDeleteRulePresenter(collectionView: RuleCollectionView, deletedRulePresenter: RulePresenter) {
        AppConfiguration.sharedConfiguration.contextPresenter().removeRulePresenter(deletedRulePresenter)
        refreshGenericRulesCollectionView()
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateAllSequences", object: nil)
    }
    
    public func didDoubleClick(collectionView: RuleCollectionView, selectedRulePresenter: RulePresenter) {
        let context = AppConfiguration.sharedConfiguration.contextPresenter()
        context.addRulePresenter(selectedRulePresenter, atIndex: context.currentRulePresenters().count)
        displayedPopover?.close()
        refreshGenericRulesCollectionView()
    }
    
    //MARK: NSPopover Delegate
    
    public func popoverWillShow(notification: NSNotification) {
        displayedPopover = notification.object as? NSPopover
    }
    
    public func popoverDidClose(notification: NSNotification) {
        displayedPopover = nil
    }
}

