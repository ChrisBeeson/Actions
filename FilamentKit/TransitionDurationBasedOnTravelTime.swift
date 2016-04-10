//
//  TransitionDurationBasedOnTravelTime.swift
//  Filament
//
//  Created by Chris Beeson on 28/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class TransitionDurationBasedOnTravelTime: Rule {
    
    override var name: String { return "RULE_NAME_TRAVEL_DUR".localized }
    override var availableToNodeType: NodeType { return [.Transition] }
    
    override init() {
        super.init()
    }
    
    // MARK: NSCoding
    
    private struct SerializationKeys {
        // static let duration = "duration"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        //   calendars = aDecoder.decodeObjectForKey("calendars") as! [EKCalendar]
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        //aCoder.encodeObject(calendars, forKey:"calendars")
    }
    
    
    // MARK: NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject  {  //TODO: NSCopy
        /*
         let clone = Sequence()
         clone.title = title.copy() as! String
         return clone
         */
        return self
    }
    
    
    
    //MARK: Mapping
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
    }
}

/*


MKDirectionsRequest *request = [MKDirectionsRequest new];
request.transportType = MKDirectionsTransportTypeWalking;
request.source = [MKMapItem mapItemForCurrentLocation]; // start from the users current location
request.destination = [MKMapItem initWithPlacemark:selectedPlacemark];
request.departureDate = [NSDate date]; // Departing now


self.directions = [[MKDirections alloc] initWithRequest:request];


[self.directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
self.walkingTime.text = [formatter stringForTimeInterval:response.expectedTravelTime];
}];


https://github.com/mattt/FormatterKit

*/