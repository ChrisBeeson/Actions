//
//  FilamentsManager.swift
//  Filament
//
//  Created by Chris Beeson on 7/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public protocol FilamentDocumentsManagerDelegate : class  {
    
    func filamentsDocumentsManagerDidUpdateContents(inserted inserted:[SequenceDocument], removed:[SequenceDocument])
}


public class FilamentDocumentsManager : DirectoryMonitorDelegate {
    
    public static let sharedManager = FilamentDocumentsManager()
    public var delegate : FilamentDocumentsManagerDelegate?
    public var documents : [SequenceDocument]                               //! All changes needs to happen through processChangeToLocalDocumentsDirectory
    private var directoryMonitor: DirectoryMonitor
    private let fileManager = NSFileManager.defaultManager()
    
    init() {
        
        documents = FilamentDocumentsManager.documentsForURLs(FilamentDocumentsManager.documentDirectoryList())
        
        directoryMonitor = DirectoryMonitor(URL: AppConfiguration.sharedConfiguration.storageDirectory)
        directoryMonitor.delegate = self
        directoryMonitor.startMonitoring()
    }
    
    deinit {
        directoryMonitor.stopMonitoring()
    }
    
    
    public func saveAllDocuments() {
        for doc in documents {
            doc.saveDocument(nil)
        }
    }
    
    
    public func documentForSequence(sequence: Sequence) -> SequenceDocument {
        
        return documents.filter{$0.unarchivedSequence! == sequence}.first!
    }
    
    
    // MARK: DirectoryMonitorDelegate
    
    public func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        processChangeToLocalDocumentsDirectory()
    }
    
    
    /** Ensures that documents[] == localDirectory **/
    
    func processChangeToLocalDocumentsDirectory() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [unowned self] in
            
            let newURLs = FilamentDocumentsManager.documentDirectoryList()
            let oldURLS = self.documents.map ( {$0.fileURL! })
            
            // inserted Urls
            
            let insertedURLs = newURLs.filter { !oldURLS.contains($0) }
            let insertedDocs = FilamentDocumentsManager.documentsForURLs(insertedURLs)
            self.documents.appendContentsOf(insertedDocs)
            
            // removed Urls
            
            let removedURLs = oldURLS.filter { !newURLs.contains($0) }
            
            var removedDocs = [SequenceDocument]()
            for url in removedURLs {
                for doc in self.documents {
                    if doc.fileURL == url {
                        removedDocs.append(doc)
                    }
                }
            }
            
            self.documents.removeObjects(removedDocs)
            
            self.delegate?.filamentsDocumentsManagerDidUpdateContents(inserted:insertedDocs, removed:removedDocs)
        }
    }
}


// MARK: Filesystem Helpers

public extension FilamentDocumentsManager {
    
    class func documentDirectoryList() -> ([NSURL]) {
        
        let fileManager = NSFileManager.defaultManager()
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory
        
        do {
            return try fileManager.contentsOfDirectoryAtURL(storageDir, includingPropertiesForKeys: nil, options:NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        }
        catch {
            fatalError(String(error))
        }
    }
    
    
    class func documentsForURLs(urls: [NSURL]) -> [SequenceDocument] {
        
        var docs = [SequenceDocument]()
        
        let predicate = NSPredicate(format: "(pathExtension = %@)", argumentArray: [AppConfiguration.filamentFileExtension])
        let filteredURLs = urls.filter { predicate.evaluateWithObject($0) }
        
        for url in filteredURLs {
            do {
                let doc = try SequenceDocument(contentsOfURL: url, ofType:"fil")
                docs.append(doc)
            } catch {
                print(error)
            }
        }
        return docs
    }
    
    public class func permanentlyDeleteDocument(document: SequenceDocument) {
        
        let url = document.storageURL()
        let fileManager = NSFileManager.defaultManager()
        
        do {
            try fileManager.removeItemAtURL(url)
        } catch {
            print(error)
        }
    }
}


