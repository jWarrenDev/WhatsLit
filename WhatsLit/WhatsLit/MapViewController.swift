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
        
        // should fetch lit events at start
        fetchLit()
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //TODO : make segue to detail View or show table view of stories
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
  

    // MARK: - Private Methods
    
    
    @IBAction func allEvents(_ sender: Any) {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        fetchLit()
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
    
    @IBAction func zoomIntoUser(_ sender: Any) {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }

    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
        fetchLit()
        
    }
    
    @IBAction func showUserClubs(_ sender: Any) {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        fetchClubs()
    }
    
    
    @IBAction func showuserRestaurants(_ sender: Any) {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        fetchRestaurants()
    }
    
    
    @IBAction func showUserBars(_ sender: Any) {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        fetchBars()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //TODO: send to detail view controller and prepare for camera + video
    }
    
    // MARK: - Properties
    
    
    @IBOutlet weak var barsButton: UIBarButtonItem!
    
    @IBOutlet weak var clubButton: UIBarButtonItem!
    
    @IBOutlet weak var restaurantButton: UIBarButtonItem!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let litPlaceController = LitPlaceController()
    
    let initialLocation = CLLocation(latitude: 37.760527, longitude: -122.443776)
    
    let regionRadius: CLLocationDistance = 10000
    var type: typeSelected = typeSelected.club
    
    enum typeSelected :String {
        case restaurant
        case bar
        case club
    }

}
