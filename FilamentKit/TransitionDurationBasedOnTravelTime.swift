//
//  TransitionDurationBasedOnTravelTime.swift
//  Filament
//
//  Created by Chris Beeson on 28/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation


class TransitionDurationBasedOnTravelTime: Rule {
    
      override var name: String { return "RULE_NAME_TRAVEL_DUR".localized }
    
    override init() {
        super.init()
    }
    
    private struct SerializationKeys {
        // static let duration = "duration"
        //   static let minDuration = "minDuration"
    }
    
    required init?(coder aDecoder: NSCoder) {
        //   calendars = aDecoder.decodeObjectForKey("calendars") as! [EKCalendar]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        //aCoder.encodeObject(calendars, forKey:"calendars")
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