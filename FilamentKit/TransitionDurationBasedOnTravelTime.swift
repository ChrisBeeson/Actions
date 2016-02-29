//
//  TransitionDurationBasedOnTravelTime.swift
//  Filament
//
//  Created by Chris Beeson on 28/02/2016.
//  Copyright © 2016 Andris Ltd. All rights reserved.
//

import Foundation


class TransitionDurationBasedOnTravelTime: Rule {
    
      override var name: String { return "Travel Duration" }
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