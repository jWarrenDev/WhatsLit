//
//  LitPlaceAnnotationView.swift
//  WhatsLit
//
//  Created by Farhan on 12/25/18.
//  Copyright © 2018 Farhan. All rights reserved.
//

import MapKit

//private let multiPlaceClusterID = String(describing: LitPlaceClusterView.self)

/// - Tag: UnicycleAnnotationView
class RestaurantAnnotationView: MKMarkerAnnotationView {
    
    static let ReuseID = "RestaurantAnnotation"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        clusteringIdentifier = "cluster"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow
        markerTintColor = UIColor.restaurantColor
        glyphTintColor = .white
        glyphImage = #imageLiteral(resourceName: "restaurant")
    }
}

/// - Tag: BicycleAnnotationView
class BarAnnotationView: MKMarkerAnnotationView {
    
    static let ReuseID = "barAnnotation"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        clusteringIdentifier = "cluster"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// - Tag: DisplayConfiguration
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = UIColor.barColor
        glyphTintColor = .white
        glyphImage = #imageLiteral(resourceName: "bar")
    }
}

class ClubAnnotationView: MKMarkerAnnotationView {
    
    static let ReuseID = "clubAnnotation"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        clusteringIdentifier =  "cluster"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = UIColor.clubColor
        glyphTintColor = .white
        glyphImage = #imageLiteral(resourceName: "club")
    }
}
