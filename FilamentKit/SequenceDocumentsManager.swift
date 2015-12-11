//
//  FilamentsManager.swift
//  Filament
//
//  Created by Chris Beeson on 7/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public class SequenceDocumentsManager {
    
    public static let sharedManager = SequenceDocumentsManager()
    
    let fileManager : NSFileManager
    
    init() {
        fileManager = NSFileManager.defaultManager()
    }
    
    
    public class func documentURLs() -> ([NSURL]?) {
        
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
    
    public func documents() -> [SequenceDocument]? {
        
        guard let urls = SequenceDocumentsManager.documentURLs() else {
            return nil
        }
        
        var docs = [SequenceDocument]()
        
        for url in urls {
            do {
               let doc = try SequenceDocument(contentsOfURL: url, ofType:"fil")
                docs.append(doc)

            } catch {
                print(error)
            }
        }
        return docs
    }
    
    
    public func newSequenceDocument(title: String) {
        
        let newDoc = SequenceDocument()
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
                print ("Created new Sequence: \(title)")
            }
        })
    }
}


