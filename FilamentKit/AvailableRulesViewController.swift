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
    
    var nodePresenter: NodePresenter?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // collectionView.nodePresenter = nodePresenter
        
    }
    
    override public func viewWillLayout() {
        super.viewWillLayout()
        
    }
    
    
    //MARK:Delegate
    
}