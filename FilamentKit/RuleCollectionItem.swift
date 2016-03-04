//
//  RuleCollectionItem.swift
//  Filament
//
//  Created by Chris on 1/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class RuleCollectionItem : NSCollectionViewItem {
    
    @IBOutlet weak var rulePillView: RulePillView!
    @IBOutlet weak var label: NSTextField!
    
    var doubleClickDisplaysDetailView = true
    var rulePresenter: RulePresenter?
    
    override public var selected: Bool {
        didSet {
            updateView()
        }
    }
    
    override public func viewWillLayout() {
        super.viewWillLayout()
        
        if rulePresenter != nil { label.stringValue = rulePresenter!.name as String }
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        updateView()
    }
    
    
    func updateView() {
        
        switch selected {
        case true:
            label.textColor = NSColor.whiteColor()
            rulePillView.setColour(AppConfiguration.Palette.tokenBlueSelected.CGColor)
        case false:
            rulePillView.setColour(AppConfiguration.Palette.tokenBlue.CGColor)
            label.textColor = NSColor.blackColor()
        }
    }
    
    
    override public func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        if theEvent.clickCount < 2 { return }
        if doubleClickDisplaysDetailView == false { return }
        guard rulePresenter != nil else { fatalError("Trying to display Rule detail view, when presenter is Nil") }
        
        let popover = NSPopover()
        popover.animates = true
        popover.behavior = .Transient
        popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        
        let detailView = rulePresenter!.detailViewController()
        // detailView.nodePresenter = presenter!
        //  presenter!.addDelegate(detailView)
        
        popover.contentViewController = detailView
        popover.showRelativeToRect(self.view.frame, ofView: self.view.superview!, preferredEdge:.MaxY )
    }
}