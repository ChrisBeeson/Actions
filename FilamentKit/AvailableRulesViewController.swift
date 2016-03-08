//
//  AvailableRulesViewController.swift
//  Filament
//
//  Created by Chris on 26/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public protocol AvailableRulesArray {
    
    func availableRulePresenters() -> [RulePresenter]
}

public class AvailableRulesViewController : NSViewController {
    
    @IBOutlet weak var collectionView: RuleCollectionView!
    public var collectionViewDelegate: RuleCollectionViewDelegate?
    
    public var filterNodeType : NodeType?
    public var rulePresenters: AvailableRulesArray?

    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func viewWillLayout() {
        super.viewWillLayout()
        
        collectionView.doubleClickDisplaysItemsDetailView = false
        reloadCollectionView()
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        
        collectionView.ruleCollectionViewDelegate = collectionViewDelegate
        //  reloadCollectionView()
    }
    
    public func reloadCollectionView() {
        
        guard collectionView != nil else { return }
        assert(rulePresenters != nil)
        
        var rps = [RulePresenter]()
        
        if filterNodeType != nil {
            rps = rps.filter { $0.availableToNodeType.contains(filterNodeType!)}
        }
        collectionView.rulePresenters = rps
        collectionView.reloadData()
    }
}