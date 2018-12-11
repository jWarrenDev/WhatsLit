//
//  LitPlace.swift
//  WhatsLit
//
//  Created by Farhan on 12/10/18.
//  Copyright © 2018 Farhan. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LitPlace {
    var video: Data?
    var id: String?
    var rating: Double?
    var timestamp: String?
    var mapItem: MKMapItem?
    
    init(video: Data?, rating: Double?, id:String = UUID().uuidString, timestamp: String = Date().description, mapItem: MKMapItem?) {
        
        self.video = video
        self.rating = rating
        self.id = id
        self.timestamp = timestamp
        self.mapItem = mapItem
        
    }
}
