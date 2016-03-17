//
//  AppConfiguration.swift
//  Filament
//
//  Created by Chris on 30/10/2015.
//  Copyright © 2015 Andris Ltd. All rights reserved.
//

import Foundation
import AppKit

public class AppConfiguration: NSObject {
    
    private var _contextPresenter: ContextPresenter?
    
    public class var sharedConfiguration: AppConfiguration {
        
        struct Singleton {
            static let sharedAppConfiguration = AppConfiguration()
        }
        
        return Singleton.sharedAppConfiguration
    }
    
    override init() {
        super.init()
    }
    
    
    
    
    // Names
    
    private struct Defaults {
        static let firstLaunchKey = "FilamentConfiguration.Defaults.firstLaunchKey"
        static let storageOptionKey = "FilamentConfiguration.Defaults.storageOptionKey"
        static let storedUbiquityIdentityToken = "FilamentConfiguration.Defaults.storedUbiquityIdentityToken"
    }
    
    
    public class var defaultFilamentCalendarName:NSString {
        return NSLocalizedString("Filament", comment: "")
    }
    
    
    public class var filamentFileExtension: String {
        return "fil"
    }
    
    public class var defaultActionNodeName: String {
        return "Untitled"
    }
    
    
    public class var localizedDocumentFolderName: String {
        return NSLocalizedString("Filament", comment: "The name of the documents folder")
    }
    
    
    public class var defaultFilamentDraftName: String {
        return NSLocalizedString("Untitled", comment: "")
    }
    
    
    // User Defaults
    
    private var applicationUserDefaults: NSUserDefaults {
        return NSUserDefaults(suiteName: ApplicationGroups.primary)!
    }
    
    public private(set) var isFirstLaunch: Bool {
        get {
            registerDefaults()
            return applicationUserDefaults.boolForKey(Defaults.firstLaunchKey)
        }
        set {
            applicationUserDefaults.setBool(newValue, forKey: Defaults.firstLaunchKey)
        }
    }
    
    private func registerDefaults() {
        #if os(iOS)
            let defaultOptions: [String: AnyObject] = [
                Defaults.firstLaunchKey: true,
                Defaults.storageOptionKey: Storage.NotSet.rawValue
            ]
            #elseif os(watchOS)
            let defaultOptions: [String: AnyObject] = [
                Defaults.firstLaunchKey: true
            ]
            #elseif os(OSX)
            let defaultOptions: [String: AnyObject] = [
                Defaults.firstLaunchKey: true
            ]
        #endif
        
        applicationUserDefaults.registerDefaults(defaultOptions)
    }
    
    
    
    // Storage
    
    public enum Storage: Int { case NotSet = 0, Local, Cloud }
    public var storageOption: Storage {
        
        get {
            return .Local
            //  let value = applicationUserDefaults.integerForKey(Defaults.storageOptionKey)
            //    return Storage(rawValue: value)!
        }
        
        set {
            //   applicationUserDefaults.setInteger(newValue.rawValue, forKey: Defaults.storageOptionKey)
        }
    }
    
    
    public var isCloudAvailable: Bool {
        return NSFileManager.defaultManager().ubiquityIdentityToken != nil
    }
    
    
    public func storageDirectory() -> NSURL {
        
        switch storageOption {
            
        case .Local:
            var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            documentsPath.appendContentsOf("/"+AppConfiguration.localizedDocumentFolderName)
            
            // create folder if required
            
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(documentsPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
            
            return NSURL(fileURLWithPath: documentsPath)
            
        case .Cloud:
            if let url = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil) {
                return url
            } else {
                assertionFailure("iCloud Storage url is Nil")
            }
            
        default:
            assertionFailure("No storage option")
        }
        return NSURL()
    }

    
    
    //MARK: Context File
    
    public func saveContext() {
        
        self._contextPresenter?.save()
    }
    
    public func contextPresenter() -> ContextPresenter {
        
        if self._contextPresenter == nil {
            
            let filePath = storageDirectory().URLByAppendingPathComponent("System_Context.plist")
            self._contextPresenter =  ContextPresenter(filePath:filePath)
        }
        
        return self._contextPresenter!
    }
    
    
    
    // MARK: Ubiquity Identity Token Handling (Account Change Info)

/*
    public func hasAccountChanged() -> Bool {
        
        var hasChanged = false
        
        let currentToken: protocol<NSCoding, NSCopying, NSObjectProtocol>? = NSFileManager.defaultManager().ubiquityIdentityToken
        let storedToken: protocol<NSCoding, NSCopying, NSObjectProtocol>? = storedUbiquityIdentityToken
        
        let currentTokenNilStoredNonNil = currentToken == nil && storedToken != nil
        let storedTokenNilCurrentNonNil = currentToken != nil && storedToken == nil
        
        // Compare the tokens.
        let currentNotEqualStored = currentToken != nil && storedToken != nil && !currentToken!.isEqual(storedToken!)
        
        if currentTokenNilStoredNonNil || storedTokenNilCurrentNonNil || currentNotEqualStored {
            
            persistAccount()
            hasChanged = true
        }
        
        return hasChanged
    }
    
    private func persistAccount() {
        
        let defaults = applicationUserDefaults
        
        if let token = NSFileManager.defaultManager().ubiquityIdentityToken {
            
            let ubiquityIdentityTokenArchive = NSKeyedArchiver.archivedDataWithRootObject(token)
            
            defaults.setObject(ubiquityIdentityTokenArchive, forKey: Defaults.storedUbiquityIdentityToken)
        }
        else {
            
            defaults.removeObjectForKey(Defaults.storedUbiquityIdentityToken)
        }
    }
    
    // MARK: Convenience
    
    private var storedUbiquityIdentityToken: protocol<NSCoding, NSCopying, NSObjectProtocol>? {
        
        var storedToken: protocol<NSCoding, NSCopying, NSObjectProtocol>?
        
        // Determine if the logged in iCloud account has changed since the user last launched the app.
        let archivedObject: AnyObject? = applicationUserDefaults.objectForKey(Defaults.storedUbiquityIdentityToken)
        
        if let ubiquityIdentityTokenArchive = archivedObject as? NSData,
            let archivedObject = NSKeyedUnarchiver.unarchiveObjectWithData(ubiquityIdentityTokenArchive) as? protocol<NSCoding, NSCopying, NSObjectProtocol> {
                storedToken = archivedObject
        }
        
        return storedToken
    }
    */

    // Bundle
    
    private struct Bundle {
        
        // static var prefix = NSBundle.mainBundle().objectForInfoDictionaryKey("AAPLListerBundlePrefix") as! String
        
        static var prefix = "com.andris"
    }
    
    #if os(OSX)
    public struct App {
        public static let bundleIdentifier = "\(Bundle.prefix).FilamentOSX"
    }
    #endif
    
    struct ApplicationGroups {
        
        static let primary = "group.\(Bundle.prefix).Filament.Documents"
    }
    
    
    // Colours 
    
    public struct Palette {
        
        public static let selectionBlue = NSColor(red: 0.6, green: 0.75, blue: 0.9, alpha: 1.0)
        public static let lightGreyStroke = NSColor(calibratedWhite:0.70, alpha:1.0)
        public static let lightGreyFill = NSColor(calibratedWhite:0.96, alpha:1.0)
        
        public static let verylightGreyStroke = NSColor(calibratedWhite:0.85, alpha:1.0)
        public static let verylightGreyFill = NSColor(calibratedWhite:0.98, alpha:1.0)
        
        public static let greenFill = NSColor(calibratedRed: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)
        public static let greenStroke = NSColor(calibratedRed: 0.1, green: 0.8, blue: 0.1, alpha: 1.0)
        
        public static let redFill =  NSColor(calibratedRed: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
        public static let redStroke = NSColor(calibratedRed: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)
        
        public static let blueFill = NSColor(calibratedRed: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
        public static let blueStroke = NSColor(calibratedRed: 0.1, green: 0.1, blue: 0.8, alpha: 1.0)
        
        public static let tokenBlue = NSColor(calibratedRed: 0.745, green: 0.839, blue: 0.922, alpha:1.0)
        public static let tokenBlueSelected = NSColor(calibratedRed: 0.435, green: 0.694, blue: 0.933, alpha: 1.00)
        
        public static let buttonSelectionBlue = NSColor(calibratedRed: 0.075, green: 0.345, blue: 1.0, alpha: 1.00)
    }
    
    
    public struct UTI {
        
        public static let rule = "com.andris.filament.pasteboard.rule"
        public static let node = "com.andris.filament.pasteboard.node"
        public static let sequence = "com.andris.filament.pasteboard.sequence"
    }
    
    // Beta Helpers 
    
    public class func featureNotYetImplimented() {
        let alert = NSAlert()
        alert.informativeText = "This feature isn't implimented yet"
        alert.showsHelp = false
        alert.addButtonWithTitle("Ok")
        alert.runModal()
    }
    
}