//
//  LitPlaceController.swift
//  WhatsLit
//
//  Created by Farhan on 12/10/18.
//  Copyright © 2018 Farhan. All rights reserved.
//

import Foundation
import MapKit

class LitPlaceController {
    
    public private(set) var places = [LitPlace]()
    
    func fetchLitPlaces(with name: String, region: MKCoordinateRegion, completion: @escaping ([LitPlace]? , Error?) -> Void){
        
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = name
        request.region = region
        
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if let error = error {
                return completion(nil, error)
            }
            
            guard let response = response else {
                return completion(nil, error)
            }
            
            let places = response.mapItems.compactMap({LitPlace(video: nil, rating: nil, mapItem: $0)})
            self.places = places
            completion(places, nil)
            
        }
        
    }
    
    
}
