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
                actualStartDate = NSDate().dateByAddingSeconds(1)
            } else {
                actualStartDate = nil
            }
        }
    }
    
    var actualStartDate: NSDate?
    var notificaionID: String?
    
    override init() {
        super.init()
    }
    
    
    override var eventStartTimeWindow: DTTimePeriod? {
        get {
            if actualStartDate != nil {
                return DTTimePeriod(size:.Hour , amount: 1, startingAt:actualStartDate)
            } else {
                return nil
            }
        }
    }
    
    override var eventPreferedStartDate: NSDate? { return actualStartDate }
    
    
    
    override func preSolverCodeBlock(rules rules:[Rule]) -> [Rule] {
        if actualStartDate != nil {
            var filteredRules = rules
            for rule in filteredRules {
                if rule is WaitForUserRule { continue }
                rule.inputDate = NSDate()   // Pump it with a dummy date to catch it!
                if rule.eventStartTimeWindow != nil { filteredRules.removeObject(rule) ; print("filtered Rule: \(rule.name)") }
                if rule.eventPreferedStartDate != nil { filteredRules.removeObject(rule) ; print("filtered Rule: \(rule.name)") }
                rule.inputDate = nil
            }
            print("return \(filteredRules)")
             return filteredRules

        } else {
            print("No actual start Date")
            return rules
        }
    }
    
    
    override func postSolverCodeBlock() {
        
        // Remove old notificaion
        if notificaionID != nil {
            let notif = NSUserNotification()
            notif.identifier = notificaionID
            NSUserNotificationCenter.defaultUserNotificationCenter().removeScheduledNotification(notif)
        }
        
        // Schedule Notification
        if userContinued == false && solvedPeriod != nil {
            if let notificationDate = solvedPeriod!.StartDate {
                let notif = NSUserNotification()
                notif.title = "RULE_WAIT_FOR_USER_NOTIFICATION_PREFIX".localized + (owner != nil ? owner!.title : "")
                notif.informativeText = "RULE_WAIT_FOR_USER_NOTIFICATION_TEXT".localized
                notif.deliveryDate = notificationDate
                //  notif.deliveryDate = NSDate().dateByAddingSeconds(5)
                notificaionID = notif.identifier
                NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification(notif)
            }
        }
    }
    
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        static let completed = "completed"
        static let actualStartDate = "actualStartDate"
        static let notificaionID = "notificaionID"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        userContinued = aDecoder.decodeBoolForKey(SerializationKeys.completed)
        actualStartDate = aDecoder.decodeObjectForKey(SerializationKeys.actualStartDate) as? NSDate
        notificaionID = aDecoder.decodeObjectForKey(SerializationKeys.notificaionID) as? String
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBool(userContinued, forKey:SerializationKeys.completed)
        aCoder.encodeObject(actualStartDate, forKey:SerializationKeys.actualStartDate)
        aCoder.encodeObject(notificaionID, forKey:SerializationKeys.notificaionID)
    }
    
    
    // MARK: NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject  {
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
    
    override func mapping(map: Map) {
        super.mapping(map)
        userContinued <- map[SerializationKeys.completed]
        actualStartDate <- (map[SerializationKeys.actualStartDate], DateTransform())
        notificaionID <- map[SerializationKeys.notificaionID]
    }
}