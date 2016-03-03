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
    
    override public var selected: Bool {
        didSet {
            
            switch selected {
            case true:
                label.textColor = NSColor.whiteColor()
                 rulePillView.setColour(AppConfiguration.Palette.tokenBlueSelected.CGColor)
            case false:
                rulePillView.setColour(AppConfiguration.Palette.tokenBlue.CGColor)
                label.textColor = NSColor.blackColor()
            }
        }
    }
}
