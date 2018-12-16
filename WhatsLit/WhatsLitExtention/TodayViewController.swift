//
//  TodayViewController.swift
//  WhatsLitExtention
//
//  Created by Farhan on 12/15/18.
//  Copyright © 2018 Farhan. All rights reserved.
//

import UIKit
import NotificationCenter
import MapKit
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let litPlaceController = LitPlaceController()
    let initialLocation = CLLocation(latitude: 37.760527, longitude: -122.443776)
    
    // MARK: - MapViewDelegate / CoreLocation
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Could not find location due to error: \(error)");
        let alert = UIAlertController(title: "Could not find your location", message: "There was an error finding your location. Try restarting the app or zoom into see what's lit around you!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Access the last object from locations to get perfect current location
        if let location = locations.last {
            let span = MKCoordinateSpan(latitudeDelta: 0.00775, longitudeDelta: 0.00775)
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            let region = MKCoordinateRegion(center: myLocation, span: span)
            mapView.setRegion(region, animated: true)
        }
        mapView.showsUserLocation = true
        manager.stopUpdatingLocation()
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let litPlace = annotation as? LitPlace else { return nil }
        
        // custom image annotation
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: litPlace) as! MKMarkerAnnotationView
        annotationView.glyphImage = UIImage(named: litPlace.type!)
        annotationView.clusteringIdentifier = "cluster"
        if annotation is MKUserLocation { return nil }
            
        else {
            
            annotationView.displayPriority = .defaultHigh
            
            if litPlace.type == "club" {
                annotationView.markerTintColor = .purple
            } else if litPlace.type == "restaurant" {
                annotationView.markerTintColor = .orange
            } else if litPlace.type == "bar" {
                annotationView.markerTintColor = .blue
            }
            annotationView.glyphTintColor = .white
            
            //            annotationView.canShowCallout = true
            annotationView.isUserInteractionEnabled = true
            annotationView.calloutOffset = CGPoint(x: -5, y: 5)
            
            
            return annotationView
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded

        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        
        mapView.delegate = self;
        fetchLit()
        locationManager.startUpdatingLocation()
        centerMapOnLocation(location: mapView?.userLocation.location ?? initialLocation)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: 7000, longitudinalMeters: 8000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: view.frame.width, height: 400)
            //Instead of table content you can user user own size
        } else if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
            
        }
    }
    
    
    private func fetchLit(){
        // Populate with most recently posted
        fetchBars()
        fetchClubs()
        fetchRestaurants()
    }
    
    private func fetchClubs(){
        
        litPlaceController.fetchLitPlaces(with: "Clubs", region: mapView.region) { (places, error) in
            
            if let error = error {
                NSLog("There was an \(error)")
                return
            }
            
            guard let places = places else {return}
            for place in places {
                place.type = "club"
            }
            
            DispatchQueue.main.async {
                //                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(places)
            }
            
        }
        
    }
    
    private func fetchRestaurants(){
        
        litPlaceController.fetchLitPlaces(with: "Restaurants", region: mapView.region) { (places, error) in
            
            if let error = error {
                NSLog("There was an \(error)")
                return
            }
            
            guard let places = places else {return}
            for place in places {
                place.type = "restaurant"
            }
            
            DispatchQueue.main.async {
                //                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(places)
            }
            
        }
        
    }
    
    private func fetchBars(){
        
        litPlaceController.fetchLitPlaces(with: "Bars", region: mapView.region) { (places, error) in
            
            if let error = error {
                NSLog("There was an \(error)")
                return
            }
            
            guard let places = places else {return}
            for place in places {
                place.type = "bar"
            }
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations(places)
            }
            
        }
        
    
     
    }
}
