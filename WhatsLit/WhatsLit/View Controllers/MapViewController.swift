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
import CardStackController

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        mapView.showsCompass = true
        mapView.delegate = self;
        centerMapOnLocation(location: initialLocation)
        
        // should fetch lit events at start
        fetchLit()
        
        registerAnnotationViewClasses()
        
    }
    
    // MARK: - MapViewDelegate / CoreLocation
    
    private func registerAnnotationViewClasses() {
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClubAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(BarAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(LitPlaceClusterView.self, forAnnotationViewWithReuseIdentifier: "nondefaultcluster")
    }
    
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
        
        if annotation is MKUserLocation { return nil }
        
        else {
            
            if litPlace.type == "club" {
                let AV = ClubAnnotationView(annotation: annotation, reuseIdentifier: ClubAnnotationView.ReuseID)
                if self.shouldCluster {
                    AV.clusteringIdentifier = "nondefaultcluster"
                }
                return AV
            } else if litPlace.type == "restaurant" {
                let AV = RestaurantAnnotationView(annotation: annotation, reuseIdentifier: RestaurantAnnotationView.ReuseID)
                if self.shouldCluster {
                    AV.clusteringIdentifier = "nondefaultcluster"
                }
                return AV
            } else  {
                let AV = BarAnnotationView(annotation: annotation, reuseIdentifier: BarAnnotationView.ReuseID)
                if self.shouldCluster {
                    AV.clusteringIdentifier = "nondefaultcluster"
                }
                return AV
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //TODO : make segue to detail View or show table view of stories
        
        guard let annotation = mapView.selectedAnnotations.first else {return}
        if annotation.isKind(of: MKClusterAnnotation.self){
            return
        } else {
        
        performSegue(withIdentifier: "showDetail", sender: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomLevel = Int(log2(zoomWidth))
        self.currentZoomLevel = zoomLevel
    }
    
  

    // MARK: - Private Methods
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.fetchLit()
        }
        
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
        if segue.identifier == "showDetail" {
            let destVC = segue.destination as? CameraViewController
            destVC?.litPlaceController = litPlaceController
            
            guard let annotation = mapView.selectedAnnotations.first else {return}
//            if annotation.isKind(of: MKClusterAnnotation.self){
//                fatalError()
//            }
            guard let title = annotation.title else {return}
            let place = litPlaceController.getLitPlace(with: title!)
            destVC?.place = place
            
        }
        if segue.identifier == "tableView" {
            let destVC = segue.destination as? PlacesTableViewController
            destVC?.litPlaceController = litPlaceController
        }
        
    }
    
    
    
    // MARK: - Properties
    
    private let maxZoomLevel = 9
    private var previousZoomLevel: Int?
    private var currentZoomLevel: Int?  {
        willSet {
            self.previousZoomLevel = self.currentZoomLevel
        }
        didSet {
            // if we have crossed the max zoom level, request a refresh
            // so that all annotations are redrawn with clustering enabled/disabled
            guard let currentZoomLevel = self.currentZoomLevel else { return }
            guard let previousZoomLevel = self.previousZoomLevel else { return }
            var refreshRequired = false
            if currentZoomLevel > self.maxZoomLevel && previousZoomLevel <= self.maxZoomLevel {
                refreshRequired = true
            }
            if currentZoomLevel <= self.maxZoomLevel && previousZoomLevel > self.maxZoomLevel {
                refreshRequired = true
            }
            if refreshRequired {
                // remove the annotations and re-add them, eg
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    private var shouldCluster: Bool {
        if let zoomLevel = self.currentZoomLevel, zoomLevel <= maxZoomLevel {
            return false
        }
        return true
    }
    
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
