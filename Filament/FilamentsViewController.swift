//
//  FilamentsViewController.swift
//  Filament
//
//  Created by Chris Beeson on 1/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Cocoa
import FilamentKit

class FilamentsViewController:  NSViewController {

    @IBOutlet weak var stackView: NSStackView!
    
    override func viewWillAppear() {
        
        populateStackView()
    }
    
    
    func populateStackView() {
        
        let documents = SequenceDocumentsController.sharedController.documents()
        print(documents)
    }
}
