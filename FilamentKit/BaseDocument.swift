//
//  Base.swift
//  Filament
//
//  Created by Chris on 29/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation

class BaseDocument: NSObject, NSCopying, NSCoding {
    
    // This is in preparation for V2 where we can group muliple sequences.
    
    var version = "1.0"
    var sequences = [Sequence]()    // There is only 1 sequence in here
    
    // All these are unused at this time
    // ---------------------------------
    var title: String = ""
    var date: NSDate?
    var startsAtDate = true
    var generalRules = [Rule]()
    var uuid = NSUUID()
    // ---------------------------------
    
    // MARK: Initializers
    override init () {
        super.init()
    }
    
    init(name:String, sequences:[Sequence]) {
        
        self.title = name
        self.sequences = sequences.map { $0.copy() as! Sequence}
        super.init()
    }
    
    // MARK: NSCoding
    private struct SerializationKeys {
        static let version = "version"
        static let title = "title"
        static let date = "date"
        static let startsAtDate = "startsAtDate"
        static let uuid = "uuid"
        static let generalRules = "generalRules"
        static let sequences = "sequences"
    }
    
    required init?(coder aDecoder: NSCoder) {
        version = aDecoder.decodeObjectForKey(SerializationKeys.version) as! String
        title = aDecoder.decodeObjectForKey(SerializationKeys.title) as! String
        date = aDecoder.decodeObjectForKey(SerializationKeys.date) as? NSDate
        startsAtDate = aDecoder.decodeObjectForKey(SerializationKeys.startsAtDate) as! Bool
        uuid = aDecoder.decodeObjectForKey(SerializationKeys.uuid) as! NSUUID
        generalRules = aDecoder.decodeObjectForKey(SerializationKeys.generalRules) as! [Rule]
        sequences = aDecoder.decodeObjectForKey(SerializationKeys.sequences) as! [Sequence]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(version, forKey: SerializationKeys.version)
        aCoder.encodeObject(title, forKey: SerializationKeys.title)
        aCoder.encodeObject(date, forKey: SerializationKeys.date)
        aCoder.encodeObject(startsAtDate, forKey: SerializationKeys.startsAtDate)
        aCoder.encodeObject(uuid, forKey: SerializationKeys.uuid)
        aCoder.encodeObject(generalRules, forKey: SerializationKeys.generalRules)
        aCoder.encodeObject(sequences, forKey: SerializationKeys.sequences)
    }
    
    
    // MARK: NSCopying
    func copyWithZone(zone: NSZone) -> AnyObject  {
        let clone = BaseDocument()
        clone.title = title.copy() as! String
        clone.date = date
        clone.startsAtDate = startsAtDate
        clone.generalRules =  NSArray(array:generalRules, copyItems: true) as! [Rule]
        clone.sequences =  NSArray(array:sequences, copyItems: true) as! [Sequence]
        return clone
    }
    
    var filename: String {
        var filename = uuid.UUIDString
        filename.appendContentsOf("."+AppConfiguration.filamentFileExtension)
        return filename
    }
    
    // Description
    override var description: String {
        return " \(title)"
    }
    
    
    // MARK: Equality
    override  func isEqual(object: AnyObject?) -> Bool {
        if let base = object as? BaseDocument {
            if uuid == base.uuid  {
                return true
            }
            return false
        }
        return false
}
}