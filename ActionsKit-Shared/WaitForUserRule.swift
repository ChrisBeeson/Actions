//
//  WaitForUserRule.swift
//  Actions
//
//  Created by Chris on 29/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import DateTools


class WaitForUserRule : Rule {
    
    override var name: String { return "RULE_NAME_WAIT".localized }
    override var availableToNodeType: NodeType { return [.Action] }
    override var options: RoleOptions { return [.RequiresSolvedPeriod] }
    
    var userContinued : Bool = false {
        didSet {
            if userContinued == true {
                actualStartDate = (Date() as NSDate).addingSeconds(1)
            } else {
                actualStartDate = nil
            }
        }
    }
    
    var actualStartDate: Date?
    var notificaionID: String?
    
    override init() {
        super.init()
    }
    
    
    override var eventStartTimeWindow: DTTimePeriod? {
        get {
            if actualStartDate != nil {
                return DTTimePeriod(size:.hour , amount: 1, startingAt:actualStartDate)
            } else {
                return nil
            }
        }
    }
    
    override var eventPreferedStartDate: Date? { return actualStartDate }
    
    
    
    override func preSolverCodeBlock(rules:[Rule]) -> [Rule] {
        if actualStartDate != nil {
            var filteredRules = rules
            for rule in filteredRules {
                if rule is WaitForUserRule { continue }
                rule.inputDate = Date()   // Pump it with a dummy date to catch it!
                if rule.eventStartTimeWindow != nil { filteredRules.removeObject(rule) }
                if rule.eventPreferedStartDate != nil { filteredRules.removeObject(rule) }
                rule.inputDate = nil
            }
             return filteredRules

        } else {
            return rules
        }
    }
    
    
    override func postSolverCodeBlock() {
        
        // Remove old notificaion
        if notificaionID != nil {
            let notif = NSUserNotification()
            notif.identifier = notificaionID
            NSUserNotificationCenter.default.removeScheduledNotification(notif)
        }
        
        // Schedule Notification
        if userContinued == false && solvedPeriod != nil {
            if let notificationDate = solvedPeriod!.startDate {
                let notif = NSUserNotification()
                notif.title = "RULE_WAIT_FOR_USER_NOTIFICATION_PREFIX".localized + (owner != nil ? owner!.title : "")
                notif.informativeText = "RULE_WAIT_FOR_USER_NOTIFICATION_TEXT".localized
                notif.deliveryDate = notificationDate
                //  notif.deliveryDate = NSDate().dateByAddingSeconds(5)
                notificaionID = notif.identifier
                NSUserNotificationCenter.default.scheduleNotification(notif)
            }
        }
    }
    
    
    // MARK: NSCoding
    
    fileprivate struct SerializationKeys {
        static let completed = "completed"
        static let actualStartDate = "actualStartDate"
        static let notificaionID = "notificaionID"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        userContinued = aDecoder.decodeBool(forKey: SerializationKeys.completed)
        actualStartDate = aDecoder.decodeObject(forKey: SerializationKeys.actualStartDate) as? Date
        notificaionID = aDecoder.decodeObject(forKey: SerializationKeys.notificaionID) as? String
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(userContinued, forKey:SerializationKeys.completed)
        aCoder.encode(actualStartDate, forKey:SerializationKeys.actualStartDate)
        aCoder.encode(notificaionID, forKey:SerializationKeys.notificaionID)
    }
    
    
    // MARK: NSCopying
    
    override func copy(with zone: NSZone?) -> AnyObject  {
        let clone = WaitForUserRule()
        clone.userContinued = self.userContinued
        clone.actualStartDate = self.actualStartDate
        clone.notificaionID = self.notificaionID
        return clone
    }
    
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(_ map: Map) {
        super.mapping(map)
        userContinued <- map[SerializationKeys.completed]
        actualStartDate <- (map[SerializationKeys.actualStartDate], DateTransform())
        notificaionID <- map[SerializationKeys.notificaionID]
    }
}
