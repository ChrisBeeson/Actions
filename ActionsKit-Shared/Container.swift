//
//  Base.swift
//  Actions
//
//  Created by Chris on 29/03/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class Container: NSObject, NSCopying, NSCoding, Mappable {
    
    // This is in preparation for V2 where we can group muliple sequences.
    
    var version = "1.0"
    var sequences = [Sequence]()    // There is only 1 sequence in here
    
    // All these are unused at this time
    // ---------------------------------
    var title: String = ""
    var date: Date?
    var timeDirection = TimeDirection.forward
    var generalRules = [Rule]()
    var uuid:String = UUID().uuidString
    // ---------------------------------
    
    // MARK: Initializers
    override init () {
        super.init()
    }
    
    init(name:String, sequences:[Sequence]) {
        self.title = name
        self.sequences = sequences
        super.init()
    }
    
    deinit {
        //  print("Container deinit")
    }
    
    
    // MARK: NSCoding
    fileprivate struct SerializationKeys {
        static let version = "version"
        static let title = "title"
        static let date = "date"
        static let timeDirection = "timeDirection"
        static let uuid = "uuid"
        static let generalRules = "generalRules"
        static let sequences = "sequences"
    }
    
    required init?(coder aDecoder: NSCoder) {
        version = aDecoder.decodeObject(forKey: SerializationKeys.version) as! String
        title = aDecoder.decodeObject(forKey: SerializationKeys.title) as! String
        date = aDecoder.decodeObject(forKey: SerializationKeys.date) as? Date
        timeDirection = TimeDirection(rawValue: aDecoder.decodeInteger(forKey: SerializationKeys.timeDirection))!
        uuid = aDecoder.decodeObject(forKey: SerializationKeys.uuid) as! String
        generalRules = aDecoder.decodeObject(forKey: SerializationKeys.generalRules) as! [Rule]
        sequences = aDecoder.decodeObject(forKey: SerializationKeys.sequences) as! [Sequence]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(version, forKey: SerializationKeys.version)
        aCoder.encode(title, forKey: SerializationKeys.title)
        aCoder.encode(date, forKey: SerializationKeys.date)
        aCoder.encode(timeDirection.rawValue, forKey: SerializationKeys.timeDirection)
        aCoder.encode(uuid, forKey: SerializationKeys.uuid)
        aCoder.encode(generalRules, forKey: SerializationKeys.generalRules)
        aCoder.encode(sequences, forKey: SerializationKeys.sequences)
    }
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
    }
    
     func mapping(_ map: Map) {
        version         <- map[SerializationKeys.version]
        title           <- map[SerializationKeys.title]
        date            <- (map[SerializationKeys.date], DateTransform())
        timeDirection   <- (map[SerializationKeys.timeDirection], EnumTransform())
        uuid            <- map[SerializationKeys.uuid]
        generalRules    <- map[SerializationKeys.generalRules]
        sequences       <- map[SerializationKeys.sequences]
    }
    
    
    // MARK: NSCopying
    func copy(with zone: NSZone?) -> Any  {
        let clone = Container()
        clone.title = title.copy() as! String
        clone.date = date
        clone.timeDirection = timeDirection
        clone.generalRules =  NSArray(array:generalRules, copyItems: true) as! [Rule]
        clone.sequences =  NSArray(array:sequences, copyItems: true) as! [Sequence]
        return clone
    }
    
    var filename: String {
        var filename = uuid
        filename.append("."+AppConfiguration.applicationFileExtension)
        return filename
    }
    
    // Description
    override var description: String {
        return " \(title)"
    }
    
    
    // MARK: Equality
    override  func isEqual(_ object: Any?) -> Bool {
        if let Container = object as? Container {
            if uuid == Container.uuid  {
                return true
            }
            return false
        }
        return false
}
}
