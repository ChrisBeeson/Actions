//
//  FilamentsManager.swift
//  Filament
//
//  Created by Chris Beeson on 7/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public protocol SequenceDocumentsDelegate : class  {
    
    func sequenceManagerDidUpdateContents(insertedURLs insertedURLs: [NSURL], removedURLs: [NSURL], updatedURLs: [NSURL])
}

public class SequenceDocumentsManager {
    
    public static let sharedManager = SequenceDocumentsManager()
    public var delegate: SequenceDocumentsDelegate?
    
    private var _documents : [SequenceDocument]?
    
    let fileManager : NSFileManager
    
    init() {
        fileManager = NSFileManager.defaultManager()
        _documents = loadDocuments()
    }
    
    
    func loadDocuments() -> [SequenceDocument]? {
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
    
    // MARK: DirectoryMonitorDelegate
    
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        //  processChangeToLocalDocumentsDirectory()
    }
    
    // MARK: Convenience
    
    /*
    
    func processChangeToLocalDocumentsDirectory() {
        
        let defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        dispatch_async(defaultQueue) {
            let fileManager = NSFileManager.defaultManager()
            
            do {
                // Fetch the list documents from containerd documents directory.
                let localDocumentURLs = try fileManager.contentsOfDirectoryAtURL(AppConfiguration.sharedConfiguration.storageDirectory, includingPropertiesForKeys: nil, options: .SkipsPackageDescendants)
                
                
                let predicate = NSPredicate(format: "(pathExtension = %@)", argumentArray: [AppConfiguration.filamentFileExtension])
                
                let localListURLs = localDocumentURLs.filter { predicate.evaluateWithObject($0) }
                
                if !localListURLs.isEmpty {
                    let insertedURLs = localListURLs.filter { !self.currentLocalContentsURLs.contains($0) }
                    let removedURLs = self.currentLocalContentsURLs.filter { !localListURLs.contains($0) }
                    
                    self.delegate?.listCoordinatorDidUpdateContents(insertedURLs: insertedURLs, removedURLs: removedURLs)
                    
                    self.currentLocalContents = localListURLs
                }
            }
            catch let error as NSError {
                print("An error occurred accessing the contents of a directory. Domain: \(error.domain) Code: \(error.code)")
            }
                // Requiring an additional catch to satisfy exhaustivity is a known issue.
            catch {}
            
        }
    }
*/
}


