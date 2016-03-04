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
    
    var nodePresenter: NodePresenter? {
        didSet {
            //  reloadCollectionView()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func viewWillLayout() {
        super.viewWillLayout()
        
          reloadCollectionView()
    }
    
    override public func viewWillAppear() {
        super.viewWillAppear()
        //  reloadCollectionView()
    }
    
    func reloadCollectionView() {
        
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