//
//  SwiftCollectionView+DynamicDataSource.swift
//  Filament
//
//  Created by Chris Beeson on 27/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

extension SequenceCollectionView {
    
    func calculateLayoutState() {
        guard presenter != nil else { return }
        
        switch (presenter!.dateIsStartDate) {
        case true:
            if presenter!.currentState == .Completed { currentLayoutState = .StartDateWithoutAddButton } else {currentLayoutState = .StartDateWithAddButton }
        case false:
            if presenter!.currentState == .Completed { currentLayoutState = .EndDateWithoutAddButton } else {currentLayoutState = .EndDateWithAddButton }
        }
    }
    
    func dynamicIndexForNodeIndex(indexPaths:Set<NSIndexPath>) ->  Set<NSIndexPath>{
        var set = Set<NSIndexPath>(minimumCapacity: indexPaths.count)
        let modifier = currentLayoutState == .EndDateWithoutAddButton ? 0 : 1
        for path in indexPaths {
            set.insert(NSIndexPath(forItem: path.item + modifier, inSection: 0))
        }
        return set
    }
    
    func nodeIndexForDynamicIndex(indexPaths:Set<NSIndexPath>) -> Set<NSIndexPath> {
        var set = Set<NSIndexPath>(minimumCapacity: indexPaths.count)
        let modifier = currentLayoutState == .EndDateWithoutAddButton ? 0 : 1
        for path in indexPaths {
            set.insert(NSIndexPath(forItem: path.item - modifier, inSection: 0))
        }
        return set
    }
    
    
    func itemForIndexPath(path: NSIndexPath) -> NSCollectionViewItem? {
        //  Swift.print("Index Path: \(path.item)  item:\(itemTypeAtIndex(path))")
        
        switch itemTypeAtIndex(path) {
        case .Date: return makeDateItem(path)
        case .AddButton: return makeAddButton(path)
        case .ActionNode,.TransitionNode: return makeMainTypeNode(path, type:itemTypeAtIndex(path))
        case .Void: return nil
        }
    }
    
    func sizeForIndexPath(path: NSIndexPath) -> NSSize {
        let modifier = currentLayoutState == .EndDateWithoutAddButton ? 0 : 1
        let nodeIndex = path.item - modifier
        
        switch itemTypeAtIndex(path) {
        case .Date: return NSSize(width: 55,height: 37)
        case .AddButton: return NSSize(width: 30,height: 25)
        case .ActionNode:
            if nodeIndex >= presenter!.nodes!.count {
                Swift.print("Index out of bounds \(nodeIndex) count:\(presenter!.nodes!.count)")
                return NSSize.zero
            }
            let node = presenter!.nodes![path.item - modifier]
            let string:NSString = node.title as NSString
            let textSize: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(14.0, weight:NSFontWeightThin) ])
            return NSSize(width: textSize.width + 30.4, height: 35)
            
        case  .TransitionNode:
            if nodeIndex >= presenter!.nodes!.count {
                Swift.print("Index out of bounds \(nodeIndex) count:\(presenter!.nodes!.count)")
                return NSSize.zero
            }
            let node = presenter!.nodes![path.item - modifier]
            let string:NSString = node.title as NSString
            let textSize: CGSize = string.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(9, weight:NSFontWeightRegular) ])
            return NSSize(width:textSize.width + 40, height: 24)
        case .Void: fatalError()
        }
    }
    
    func makeDateItem(path: NSIndexPath) -> NSCollectionViewItem {
        let item = makeItemWithIdentifier("DateNodeCollectionViewItem", forIndexPath: path) as! DateNodeCollectionViewItem
        item.sequencePresenter = self.presenter!
        presenter?.addDelegate(item)
        item.updateView()
        return item
    }
    
    func makeAddButton(path: NSIndexPath) -> NSCollectionViewItem {
        let item = makeItemWithIdentifier("AddNewNodeCollectionViewItem", forIndexPath: path) as! AddNewNodeCollectionViewItem
        item.sequencePresenter = presenter
        return item
    }
    
    func makeMainTypeNode(path: NSIndexPath, type:SequenceCollectionViewItemType ) -> NSCollectionViewItem {
        var item: NodeCollectionViewItem
        let modifier = currentLayoutState == .EndDateWithoutAddButton ? 0 : 1
        let node = presenter!.nodes![path.item - modifier]
        
        switch type {
        case .ActionNode:
            item = makeItemWithIdentifier("ActionNodeCollectionViewItem", forIndexPath: path) as! NodeCollectionViewItem
            
        case .TransitionNode:
            item = makeItemWithIdentifier("TransitionNodeCollectionViewItem", forIndexPath: path) as! NodeCollectionViewItem
            
        default: item = NodeCollectionViewItem()
        }
        if item.presenter != presenter!.presenterForNode(node) {
            item.presenter = presenter!.presenterForNode(node)
        }
        item.indexPath = path
        return item
    }
    
    
    func indexOfItemType(itemType: SequenceCollectionViewItemType) -> [NSIndexPath] {
        guard presenter != nil else { fatalError() }
        guard presenter!.nodes != nil else { fatalError() }
        
        switch itemType {
        case .ActionNode:
            var paths = [NSIndexPath]()
            for (index, node) in presenter!.nodes!.enumerate() {
                if node.type == .Action {
                    paths.append(NSIndexPath(index: index+1))
                }
            }
            return paths
            
        case .TransitionNode:
            var paths = [NSIndexPath]()
            for (index, node) in presenter!.nodes!.enumerate() {
                if node.type == .Transition {
                    paths.append(NSIndexPath(index: index+1))
                }
            }
            return paths
            
        case .Date:
            switch self.currentLayoutState {
            case .StartDateWithAddButton, .StartDateWithoutAddButton:
                return [NSIndexPath(index: 0)]
                
            case .EndDateWithAddButton:
                return [NSIndexPath(index: presenter!.nodes!.count+2)]
                
            case .EndDateWithoutAddButton:
                return [NSIndexPath(index: presenter!.nodes!.count+1)]
            }
            
        case .AddButton:
            switch currentLayoutState {
            case .StartDateWithAddButton: return [NSIndexPath(index: presenter!.nodes!.count+2)]
            case .StartDateWithoutAddButton: return [NSIndexPath(index: -1)]
            case .EndDateWithAddButton: return [NSIndexPath(index: 0)]
            case .EndDateWithoutAddButton: return [NSIndexPath(index: -1)]
            }
            
        default: return [NSIndexPath(index: -1)]
        }
    }
    
    
    func itemTypeAtIndex(index:NSIndexPath) -> SequenceCollectionViewItemType {
        switch index.item {
        case 0:
            switch currentLayoutState {
            case .StartDateWithAddButton: return .Date
            case .StartDateWithoutAddButton: return .Date
            case .EndDateWithAddButton: return .AddButton
            case .EndDateWithoutAddButton: return .ActionNode
            }
            
        case presenter!.nodes!.count+1:
            switch currentLayoutState {
            case .StartDateWithAddButton: return .AddButton
            case .StartDateWithoutAddButton: return .Void
            case .EndDateWithAddButton: return .Date
            case .EndDateWithoutAddButton: return .Void
            }
            
        case presenter!.nodes!.count:
            switch currentLayoutState {
            case .StartDateWithAddButton: return .ActionNode
            case .StartDateWithoutAddButton: return .ActionNode
            case .EndDateWithAddButton: return .ActionNode
            case .EndDateWithoutAddButton: return .TransitionNode
            }
            
        case let x where x > 0 && x < presenter!.nodes!.count:
            let modifier = currentLayoutState == .EndDateWithoutAddButton ? 0 : 1
            if (x - modifier) > -1 && (x - modifier) < presenter!.nodes!.count {
                let node = presenter!.nodes![index.item - modifier]
                if node.type == .Action { return .ActionNode } else { return .TransitionNode }
            } else { return .Void }
            
        default: Swift.print("Got to default - Index: \(index.item)")
        }
        return .Void
    }
}