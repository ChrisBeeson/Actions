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
    
    /*
    The value of the `LISTER_BUNDLE_PREFIX` user-defined build setting is written to the Info.plist file of
    every target in Swift version of the Lister project. Specifically, the value of `LISTER_BUNDLE_PREFIX`
    is used as the string value for a key of `AAPLListerBundlePrefix`. This value is loaded from the target's
    bundle by the lazily evaluated static variable "prefix" from the nested "Bundle" struct below the first
    time that "Bundle.prefix" is accessed. This avoids the need for developers to edit both `LISTER_BUNDLE_PREFIX`
    and the code below. The value of `Bundle.prefix` is then used as part of an interpolated string to insert
    the user-defined value of `LISTER_BUNDLE_PREFIX` into several static string constants below.
    */
    
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
        public static let lightGreyStroke = NSColor(calibratedWhite:0.65, alpha:1.0)
        public static let lightGreyFill = NSColor(calibratedWhite:0.95, alpha:1.0)
        
        public static let greenFill = NSColor(calibratedRed: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)
        public static let greenStroke = NSColor(calibratedRed: 0.1, green: 0.8, blue: 0.1, alpha: 1.0)
        
        public static let redFill =  NSColor(calibratedRed: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
        public static let redStroke = NSColor(calibratedRed: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)
        
        public static let blueFill = NSColor(calibratedRed: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
        public static let blueStroke = NSColor(calibratedRed: 0.1, green: 0.1, blue: 0.8, alpha: 1.0)
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