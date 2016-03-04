//
//  AvailableRulesViewController.swift
//  Filament
//
//  Created by Chris on 26/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

public class AvailableRulesViewController : NSViewController,NSTokenFieldDelegate {
    
    @IBOutlet weak var collectionView: RuleCollectionView!
    
    public var nodePresenter: NodePresenter? {
        didSet {
            //  reloadCollectionView()
        }
    }
    
    public var collectionViewDelegate: RuleCollectionViewDelegate?
    
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
        
        assert(nodePresenter != nil)
        
        // Make a rule presenter for each available rule
        
        var rps = [RulePresenter]()
        for rule in nodePresenter!.availableRules() {
            rps.append(RulePresenter(rule: rule))
        }
        collectionView.rulePresenters = rps
        collectionView.reloadData()
    }
}