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
    private var _documents : [SequenceDocument]?
    
    let fileManager : NSFileManager
    
    init() {
        fileManager = NSFileManager.defaultManager()
        _documents = loadDocuments()
    }
    
    
    internal func loadDocuments() -> [SequenceDocument]? {
        guard let urls = documentURLs() else {
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
    
    public func saveAllDocuments() {
        if _documents == nil { return }
        
        for doc in _documents! {
            let edited = doc.documentEdited
            print("\(doc) has been edited: \(edited)")
            doc.saveDocument(nil)
        }
    }
    
    
    public func documents() -> [SequenceDocument]? {
        return _documents
    }
    
    
     func documentURLs() -> ([NSURL]?) {
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
    
    public func deleteDocumentForSequence(sequence: Sequence) {
        
        let document = _documents?.filter{$0.unarchivedSequence == sequence}.first
        if document != nil {
            
            let title = document?.unarchivedSequence!.title
            print("doc found to delete \(title)")
            
            _documents?.removeObject(document!)
            permanentlyDeleteDocument(document!)
        }
    }
    
        func permanentlyDeleteDocument(document: SequenceDocument) {
            
            let url = document.storageURL()
            let fileManager = NSFileManager.defaultManager()
            
            do {
                 try fileManager.removeItemAtURL(url)
                
            } catch {
                print(error)
            }
        }
}


