//
//  VenueAnnotation.swift
//  Revur
//
//  Created by John David on 8/31/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit
import MapKit

class VenueAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: VenueType
    var currentVenue: Venue!
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, venue: Venue) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.currentVenue = venue
        self.type = self.currentVenue.venueType
    }
}
