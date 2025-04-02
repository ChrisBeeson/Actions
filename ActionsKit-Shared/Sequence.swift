//
//  Sequence.swift
//  Actions
//
//  Created by Chris Beeson on 5/09/2015.
//  Copyright (c) 2016 Andris Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

@objc
public enum TimeDirection: Int {
    case forward
    case backward
}

class Sequence: NSObject, NSCopying, NSCoding, Mappable {
    
    var title: String = ""
    var actionNodes = [Node]()
    var transitionNodes = [Node]()
    var date: Date?
    var timeDirection = TimeDirection.forward
    var generalRules = [Rule]()
    var uuid:String = UUID().uuidString

    // MARK: Initializers
    override init () {
        super.init()
    }
    
     init(name:String, actionNodes:[Node]? = []) {
        self.title = name
        super.init()
        if let nodes = actionNodes {
            self.actionNodes = nodes
            forceCreateTransistionNodesForActionNodes()
        }
    }
    
    deinit {
        //  print("Sequence deinit")
    }
    
    // MARK: NSCoding
    fileprivate struct SerializationKeys {
        static let title = "title"
        static let actionNodes = "actionNodes"
        static let transitionNodes = "transitionNodes"
        static let date = "date"
        static let timeDirection = "timeDirection"
        static let events = "events"
        static let uuid = "uuid"
        static let generalRules = "generalRules"
    }
    
     required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: SerializationKeys.title) as! String
        actionNodes = aDecoder.decodeObject(forKey: SerializationKeys.actionNodes) as! [Node]
        transitionNodes = aDecoder.decodeObject(forKey: SerializationKeys.transitionNodes) as! [Node]
        date = aDecoder.decodeObject(forKey: SerializationKeys.date) as? Date
        timeDirection = TimeDirection(rawValue: aDecoder.decodeInteger(forKey: SerializationKeys.timeDirection))!
        uuid = aDecoder.decodeObject(forKey: SerializationKeys.uuid) as! String
        generalRules = aDecoder.decodeObject(forKey: SerializationKeys.generalRules) as! [Rule]
    }
    
     func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: SerializationKeys.title)
        aCoder.encode(actionNodes, forKey: SerializationKeys.actionNodes)
        aCoder.encode(transitionNodes, forKey: SerializationKeys.transitionNodes)
        aCoder.encode(date, forKey: SerializationKeys.date)
        aCoder.encode(timeDirection.rawValue, forKey: SerializationKeys.timeDirection)
        aCoder.encode(uuid, forKey: SerializationKeys.uuid)
        aCoder.encode(generalRules, forKey: SerializationKeys.generalRules)
    }
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(_ map: Map) {
        title           <- map[SerializationKeys.title]
        actionNodes      <- map[SerializationKeys.actionNodes]
        transitionNodes <-  map[SerializationKeys.transitionNodes]
        date            <- (map[SerializationKeys.date], DateTransform())
        timeDirection   <- (map[SerializationKeys.timeDirection], EnumTransform())
        uuid            <- map[SerializationKeys.uuid]
        generalRules    <- map[SerializationKeys.generalRules]
    }
    
    
    // MARK: NSCopying
     func copy(with zone: NSZone?) -> Any  {
        let clone = Sequence()
        clone.title = title.copy() as! String
        clone.actionNodes =  NSArray(array:actionNodes, copyItems: true) as! [Node]
        clone.transitionNodes = NSArray(array:transitionNodes, copyItems: true) as! [Node]
        clone.date = date
        clone.timeDirection = timeDirection
        clone.generalRules =  NSArray(array:generalRules, copyItems: true) as! [Rule]
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
        if let sequence = object as? Sequence {
            if uuid == sequence.uuid  {
                return true
            }
            return false
        }
        return false
    }
}
