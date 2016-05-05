//
//  FilamentsViewController.swift
//  Actions
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Cocoa
import ActionsKit
import Async

public class MainTableViewController:  NSViewController, NSTableViewDataSource, NSTableViewDelegate, ActionsDocumentManagerDelegate, RuleCollectionViewDelegate, NSPopoverDelegate {
    
    @IBOutlet weak var addGenericRuleButton: NSButton!
    @IBOutlet weak var genericRulesCollectionView: RuleCollectionView!
    @IBOutlet weak var tableView: NSTableView!
    
    private var allDocuments = [ActionsDocument]()
    private var filteredDocuments = [ActionsDocument]()
    private var filter = DocumentFilterType.Active
    private var availableGenericRulesViewController : AvailableRulesViewController?
    private var displayedPopover:NSPopover?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        ActionsDocumentManager.sharedManager.delegate = self
        allDocuments  = ActionsDocumentManager.sharedManager.documents
        
        genericRulesCollectionView.ruleCollectionViewDelegate = self
        genericRulesCollectionView.allowDrops = true
        genericRulesCollectionView.allowDropsFromType = [.Generic]
        genericRulesCollectionView.allowDeletions = true
        
        let nib =  NSNib(nibNamed: "MainTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forIdentifier: "MainTableCellView")
        
        NSNotificationCenter.defaultCenter().addObserverForName("FilamentTableViewSelectCellForView", object: nil, queue: nil) { (notification) -> Void in
            let row = self.tableView.rowForView(notification.object as! NSView)
            self.tableView.selectRowIndexes((NSIndexSet(index: row)), byExtendingSelection: false)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("RefreshMainTableView", object: nil, queue: nil) { (notification) -> Void in
            self.updateTableViewContent(true)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("LicenceStateDidChange", object: nil, queue: nil) { (notification) -> Void in
            
            func presentLicenceController() {
                let storyboard = NSStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateControllerWithIdentifier(
                    "PurchaseLicence") as! NSViewController
                self.presentViewControllerAsModalWindow(vc)
            }
            
            switch(AppConfiguration.sharedConfiguration.commerceManager.currentLicenceState) {
                
            case .Trial(let daysRemaining):
                if daysRemaining == 0 {
                    presentLicenceController()
                }
                //else if daysRemaining < 7 {}
                
            case .Expired: presentLicenceController()
                
            default:break
            }
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
    
    override public func viewDidAppear() {
        super.viewDidAppear()
        
        /*
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let vc = storyboard.instantiateViewControllerWithIdentifier("viewController")
         self.navigationController!.pushViewController(vc, animated: true)
         */
    }
    
    
    func setTableViewFilter(filter: DocumentFilterType) {
        if self.filter != filter {
            self.filter = filter
            updateTableViewContent(false)
        }
    }
    
    func updateTableViewContent(animated:Bool) {
        
        let newFilteredDocuments = ActionsDocumentManager.filterDocumentsForFilterType(allDocuments, filterType: self.filter)
        
        if animated == false {
            filteredDocuments = newFilteredDocuments
            self.tableView!.reloadData()
            self.tableView.deselectAll(self)
            return
        }
        
        Async.main {
            let oldRows = self.filteredDocuments
            let newRows = newFilteredDocuments
            let diff = oldRows.diff(newRows)
            self.filteredDocuments = newFilteredDocuments
            
            if (diff.results.count > 0) {
                let deletionIndexPaths = NSMutableIndexSet()
                diff.deletions.forEach { deletionIndexPaths.addIndex($0.idx) }
                let insertionIndexPaths = NSMutableIndexSet()
                diff.insertions.forEach { insertionIndexPaths.addIndex($0.idx) }
                
                /*
                 self.tableView?.beginUpdates()
                 self.tableView?.removeRowsAtIndexes(deletionIndexPaths, withAnimation: NSTableViewAnimationOptions.EffectFade)
                 self.tableView?.insertRowsAtIndexes(insertionIndexPaths, withAnimation: NSTableViewAnimationOptions.SlideLeft)
                 self.tableView?.endUpdates()
                 */
                //FIXME: Why is animation intermittant?
                
                self.tableView!.reloadData()
            }
        }
    }
    
    
    // MARK: TableView DataSource
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return filteredDocuments.count
    }
    
    public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeViewWithIdentifier("MainTableCellView", owner: self) as! MainTableCellView
        cellView.sequencePresenter = filteredDocuments[row].sequencePresenter
        cellView.sequencePresenter?.undoManager = self.undoManager
        cellView.sequencePresenter?.updateState(processEvents:true)
        cellView.updateCellView()
        return cellView
    }
    
    public func tableViewSelectionDidChange(notification: NSNotification) {
        for row in 0 ..< tableView.numberOfRows {
            if let cellView = tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? MainTableCellView {
                cellView.selected = tableView.isRowSelected(row)
            }
        }
    }
    
    // MARK: Filaments Manager Delegate
    
    public func actionsDocumentsManagerDidUpdateContents(inserted inserted:[ActionsDocument], removed:[ActionsDocument]) {
        self.allDocuments.removeObjects(removed)
        self.allDocuments.appendContentsOf(inserted)
        self.updateTableViewContent(true)
    }
    
    
    //MARK: Menu
    
    public override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        
        switch menuItem.action {
        case #selector(MainTableViewController.newDocument(_:)):
            return true
            
        case #selector(MainTableViewController.openDocument(_:)):
            return true
            
        case #selector(MainTableViewController.paste(_:)):
            let pasteboard = NSPasteboard.generalPasteboard()
            return pasteboard.canReadItemWithDataConformingToTypes([AppConfiguration.UTI.container])
            
        case #selector(MainTableViewController.copy(_:)),
             #selector(MainTableViewController.cut(_:)),
             #selector(MainTableViewController.delete(_:)),
             #selector(MainTableViewController.saveDocumentAs(_:)):
            return self.tableView.selectedRowIndexes.count > 0 ? true : false
            
        case #selector(MainTableViewController.undo(_:)):
            return self.undoManager!.canUndo
            
        default: return false
        }
    }
    
    
    public func newDocument(event: NSEvent) {
        ActionsDocument.newDocument("NEW_DOCUMENT_DEFAULT_TITLE".localized)
    }
    
    public func openDocument(event: NSEvent) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        //    panel.allowedFileTypes = [".fil"]
        panel.beginWithCompletionHandler { (result) in
            
            if result == NSFileHandlingPanelOKButton && panel.URL != nil {
                ActionsDocument.newDocumentFromJSON(panel.URL!)
            }
        }
    }
    
    public func saveDocumentAs(event: NSEvent) {
        guard let sequence = filteredDocuments[self.tableView.selectedRow].sequencePresenter else { return }
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = sequence.representingDocument!.suggestedExportFilename
        
        panel.beginSheetModalForWindow(self.tableView.window!, completionHandler:{ (result) in
            if result == NSFileHandlingPanelOKButton && panel.URL != nil {
                sequence.representingDocument!.exportWithFilename(panel.URL!)
            }
        })
    }
    
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
            if let cellView = tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: false) as? MainTableCellView {
                cellView.sequencePresenter?.prepareForCompleteDeletion()
                ActionsDocumentManager.sharedManager.deleteDocumentForPresenter(cellView.sequencePresenter!)
            }
        default: break
        }
    }
    
    /*
     override public func keyDown(theEvent: NSEvent) {
     Swift.print(theEvent)
     }
     */
    
    
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
            ActionsDocument.newDocumentFromArchive(data)
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
    
    
    //MARK: Generic Rules Collection View
    
    @IBAction func addGenericRuleButtonPressed(sender: AnyObject) {
        if displayedPopover != nil {return }
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.delegate = self
        
        if availableGenericRulesViewController == nil {
            availableGenericRulesViewController = AvailableRulesViewController(nibName:"AvailableRulesViewController", bundle:NSBundle(identifier:"com.andris.ActionsKit"))
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

