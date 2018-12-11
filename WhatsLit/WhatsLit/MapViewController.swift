//
//  MapViewController.swift
//  WhatsLit
//
//  Created by Farhan on 12/9/18.
//  Copyright © 2018 Farhan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        
        mapView.delegate = self;
        centerMapOnLocation(location: initialLocation)
        
        fetchClubs()
        
    }
    
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

//    // func to create annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "mapAnnotation"

        // custom image annotation
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        

        return annotationView
    }
    
    private func fetchClubs(){
        
        litPlaceController.fetchLitPlaces(with: "Clubs", region: mapView.region) { (places, error) in
            
            if let error = error {
                NSLog("There was an \(error)")
                return
            }
            
            guard let places = places?.compactMap({$0.mapItem}) else {return}
            
            let annotations = places.compactMap({$0.placemark})

            self.mapView.addAnnotations(annotations)
        }
        
    }

    // MARK: - Private Methods
    
    
    @IBAction func zoomIntoUser(_ sender: Any) {
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let litPlaceController = LitPlaceController()
    
    let initialLocation = CLLocation(latitude: 37.760527, longitude: -122.443776)
    
    let regionRadius: CLLocationDistance = 12000
    

}
