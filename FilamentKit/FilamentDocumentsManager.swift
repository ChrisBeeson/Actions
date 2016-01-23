//
//  FilamentsManager.swift
//  Filament
//
//  Created by Chris Beeson on 7/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public protocol FilamentDocumentsDelegate : class  {
    
    func filamentsDocumentsManagerDidUpdateContents(insertedURLs insertedURLs: [NSURL], removedURLs: [NSURL])
}

public class FilamentDocumentsManager : DirectoryMonitorDelegate {
    
    public static let sharedManager = FilamentDocumentsManager()
    public var delegate: FilamentDocumentsDelegate?
    
    private var _documents : [SequenceDocument]?
    private var directoryMonitor: DirectoryMonitor
    let fileManager : NSFileManager
    
    init() {
        fileManager = NSFileManager.defaultManager()
        directoryMonitor = DirectoryMonitor(URL: AppConfiguration.sharedConfiguration.storageDirectory)
        directoryMonitor.delegate = self
        _documents = loadDocuments()
        directoryMonitor.startMonitoring()
    }
    
    deinit {
        directoryMonitor.stopMonitoring()
    }
    
    func loadDocuments() -> [SequenceDocument]? {
        
        guard let urls = documentURLs() else { return nil }
        
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
            //   _documents?.removeObject(document!)
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
    
    public func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        processChangeToLocalDocumentsDirectory()
    }
    
    
    func processChangeToLocalDocumentsDirectory() {
        
        let defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(defaultQueue) {
            
            var localDocumentURLs = self.documentURLs()
            if localDocumentURLs == nil  { localDocumentURLs = [NSURL]() }
            let predicate = NSPredicate(format: "(pathExtension = %@)", argumentArray: [AppConfiguration.filamentFileExtension])
            let newURLs = localDocumentURLs!.filter { predicate.evaluateWithObject($0) }
            let oldURLS = self._documents!.map ( {$0.fileURL! })
            
            if !newURLs.isEmpty {
                let insertedURLs = newURLs.filter { !oldURLS.contains($0) }
                let removedURLs = oldURLS.filter { !newURLs.contains($0) }
                self.delegate?.filamentsDocumentsManagerDidUpdateContents(insertedURLs: insertedURLs, removedURLs: removedURLs)
                
                // let docsToInsert = insertedURLs.map ({ SequenceDocument(contentsOfURL: $0, ofType:"fil") } )
                
                //_documents!.append (insertedURLs.map ( { SequenceDocument($0, ofType:"fil") } ))
            }
        }
    }
}


