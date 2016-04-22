//
//  AvailableRulesViewController.swift
//  Actions
//
//  Created by Chris on 26/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation



public class AvailableRulesViewController : NSViewController {
    
    @IBOutlet weak var collectionView: RuleCollectionView!
    public var collectionViewDelegate: RuleCollectionViewDelegate?
    
    public var displayRulesForNodeType : NodeType?
    public var availableRules : RuleAvailabiltiy?

    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func viewWillLayout() {
        super.viewWillLayout()
        
        collectionView?.doubleClickDisplaysItemsDetailView = false
        reloadCollectionView()
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        
        collectionView.ruleCollectionViewDelegate = collectionViewDelegate
        //  reloadCollectionView()
    }
    
    public func reloadCollectionView() {
        
        guard collectionView != nil else { return }
        assert(availableRules != nil)
        
        collectionView.rulePresenters = availableRules!.availableRulePresenters()
        collectionView.reloadData()
    }
}