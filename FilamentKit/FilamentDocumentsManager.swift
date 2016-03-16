//
//  FilamentsManager.swift
//  Filament
//
//  Created by Chris Beeson on 7/11/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation

public protocol FilamentDocumentsManagerDelegate : class  {
    
    func filamentsDocumentsManagerDidUpdateContents(inserted inserted:[FilamentDocument], removed:[FilamentDocument])
}


public class FilamentDocumentsManager : DirectoryMonitorDelegate {
    
    public static let sharedManager = FilamentDocumentsManager()
    public var delegate : FilamentDocumentsManagerDelegate?
    public var documents : [FilamentDocument]                               //! All changes needs to happen through processChangeToLocalDocumentsDirectory
    private var directoryMonitor: DirectoryMonitor
    private let fileManager = NSFileManager.defaultManager()
    
    init() {
        
         print("Directory: \(AppConfiguration.sharedConfiguration.storageDirectory())")
        documents = FilamentDocumentsManager.documentsForURLs(FilamentDocumentsManager.documentDirectoryList())
       
        directoryMonitor = DirectoryMonitor(URL: AppConfiguration.sharedConfiguration.storageDirectory())
        directoryMonitor.delegate = self
        directoryMonitor.startMonitoring()
    }
    
    deinit {
        directoryMonitor.stopMonitoring()
    }
    
    
    public func saveAllDocuments() {
        for doc in documents {
            doc.save()  //forcefully save
        }
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
            
            var removedDocs = [FilamentDocument]()
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
    
    public func deleteDocumentForPresenter(presenter:SequencePresenter) {
        
        let docToDel = self.documentForSequence(presenter.sequence)
        FilamentDocumentsManager.permanentlyDeleteDocument(docToDel)
    }
    
    func documentForSequence(sequence: Sequence) -> FilamentDocument {
        
        return documents.filter{$0.unarchivedSequence! == sequence}.first!
    }
}


// MARK: Export 


/*

EXPORT AS XML

NSMutableData *data = [NSMutableData data];
NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
[archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
[archiver encodeObject:artistCollection forKey:@"root"];
[archiver finishEncoding];
[data writeToFile:@"/Users/fgx/Desktop/stuff" atomically:YES];
[archiver release];

*/


// MARK: Filesystem Helpers

public extension FilamentDocumentsManager {
    
    class func documentDirectoryList() -> ([NSURL]) {
        
        let fileManager = NSFileManager.defaultManager()
        let storageDir = AppConfiguration.sharedConfiguration.storageDirectory()
        
        do {
            return try fileManager.contentsOfDirectoryAtURL(storageDir, includingPropertiesForKeys: nil, options:NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        }
        catch {
            fatalError(String(error))
        }
    }
    
    
    class func documentsForURLs(urls: [NSURL]) -> [FilamentDocument] {
        
        var docs = [FilamentDocument]()
        
        let predicate = NSPredicate(format: "(pathExtension = %@)", argumentArray: [AppConfiguration.filamentFileExtension])
        let filteredURLs = urls.filter { predicate.evaluateWithObject($0) }
        
        for url in filteredURLs {
            do {
                let doc = try FilamentDocument(contentsOfURL: url, ofType:"fil")
                docs.append(doc)
            } catch {
                print(error)
            }
        }
        return docs
    }
    
    public class func permanentlyDeleteDocument(document: FilamentDocument) {
        
        let url = document.storageURL()
        let fileManager = NSFileManager.defaultManager()
        
        do {
            try fileManager.removeItemAtURL(url)
        } catch {
            print(error)
        }
    }
}

public enum DocumentFilterType: Int { case Active = 0, Completed = 1 }

public extension FilamentDocumentsManager {
    
    public class func filterDocumentsForFilterType(documents:[FilamentDocument], filterType:DocumentFilterType) -> [FilamentDocument] {
        
        // First update all sequence statees
        documents.forEach{ $0.sequencePresenter?.updateState() }
        
        var returnDocuments = [FilamentDocument]()
        
        switch filterType {
            
        case .Active:
            
            // Active sequence are sorted in this order
            // 0. Waiting for user
            // 1. Running sequence, soonest to end is first
            // 2. WaitingForStart, soonest to start first
            // 3. how do errors fit in?
            
            
        returnDocuments = documents.filter{ $0.sequencePresenter?.currentState == SequenceState.Paused }
            
        let running = documents.filter{ $0.sequencePresenter?.currentState == SequenceState.Running }.sort({ $0.sequencePresenter!.completionDate!.compare($1.sequencePresenter!.completionDate!) == .OrderedAscending })
        returnDocuments.appendContentsOf(running)
        
        let errors = documents.filter{ $0.sequencePresenter?.currentState == SequenceState.HasFailedNode }.sort({ $0.sequencePresenter!.date!.compare($1.sequencePresenter!.date!) == .OrderedAscending })
        returnDocuments.appendContentsOf(errors)
        
        let waitingForStart = documents.filter{ $0.sequencePresenter?.currentState == SequenceState.WaitingForStart }.sort({ $0.sequencePresenter!.date!.compare($1.sequencePresenter!.date!) == .OrderedAscending })
        returnDocuments.appendContentsOf(waitingForStart)
            
        let NoStartDate = documents.filter{ $0.sequencePresenter?.currentState == SequenceState.NoStartDateSet }.sort({ $0.fileModificationDate!.compare($1.fileModificationDate!) == .OrderedAscending })
            returnDocuments.appendContentsOf(NoStartDate)


        case .Completed:
            
            returnDocuments = documents.filter{ $0.sequencePresenter?.currentState == SequenceState.Completed }
        }
        return returnDocuments
    }
}

