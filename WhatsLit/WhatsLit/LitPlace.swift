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

class LitPlace: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var url: URL?
    var phoneNumber: String?
    var video: URL?
    var id: String?
    var rating: Double?
    var timestamp: String?
    var mapItem: MKMapItem?
    var type: String?
    
    init(video: URL?, rating: Double?, id:String = UUID().uuidString, timestamp: String = Date().description, type: String?, mapItem: MKMapItem?) {
        
        self.video = video
        self.rating = rating
        self.id = id
        self.timestamp = timestamp
        self.title = mapItem?.placemark.name
        self.url = mapItem?.url
        self.phoneNumber = mapItem?.phoneNumber
        self.type = type
        self.coordinate = mapItem?.placemark.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
    }
    
    
    
    override var description: String {
        return String(describing: "\(self.id)" + "\( self.title))" + "\(self.url)" + "\(self.phoneNumber)")
    }
}
