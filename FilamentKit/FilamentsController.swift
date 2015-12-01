//
//  FilamentsManager.swift
//  Filament
//
//  Created by Chris Beeson on 7/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class FilamentsController {
    
    public static let sharedController = FilamentsController()
    let fileManager : NSFileManager
    
    init() {
        fileManager = NSFileManager.defaultManager()
    }
    
    
    class func documentURLs() -> ([NSURL]?) {
        
        let fileManager = NSFileManager.defaultManager()
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        
        do {
            let contents = try fileManager.contentsOfDirectoryAtURL(storageDir, includingPropertiesForKeys: nil, options:NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            return contents
        }
        catch {
            print(error)
            return nil
        }
    }
    
    
    func NewFilamentDocument(title: String) {
        
        let newDoc = FilamentDocument()
        let sequence = Sequence()
        sequence.title = title
        newDoc.unarchivedSequence = sequence
        
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        let url = storageDir.URLByAppendingPathComponent(sequence.filename)
        print(url)
        
        newDoc.saveToURL(url, ofType: AppConfiguration.filamentFileExtension , forSaveOperation:.SaveOperation, completionHandler: { (Err: NSError?) -> Void in
            
            if Err != nil {
                print(Err!.localizedDescription)
            } else {
                print ("saved")
            }
        })
    }
}


