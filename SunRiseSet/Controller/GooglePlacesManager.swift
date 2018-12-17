//
//  GooglePlacesManager.swift
//  SunRiseSet
//
//  Created by Admin on 12/17/18.
//  Copyright © 2018 Maksym Gontar. All rights reserved.
//

import Foundation
import GooglePlaces

class GooglePlacesManager {
    
    var placesClient:GMSPlacesClient!
    
    
    // Basic singletone
    static let shared = GooglePlacesManager()
    
    private init(){
        placesClient = GMSPlacesClient.shared()
    }
    
    func getCurrentPlace(completionHandler: @escaping (CLLocationCoordinate2D?, String?, Error?) -> Void){
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                completionHandler(nil, nil, error)
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                if let likelihood = placeLikelihoodList.likelihoods.first {
                    completionHandler(likelihood.place.coordinate, likelihood.place.formattedAddress, nil)
                }
                else{
                    completionHandler(nil, nil, CustomError.serviceError)
                }
            }
            else{
                completionHandler(nil, nil, CustomError.serviceError)
            }
        })
    }
    
    func getPlaceByID(_ placeID:String, completionHandler: @escaping (CLLocationCoordinate2D?, String?, Error?) -> Void){
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                completionHandler(nil, nil, error)
                return
            }
            
            guard let place = place else {
                completionHandler(nil, nil, CustomError.serviceError)
                return
            }
            completionHandler(place.coordinate, place.formattedAddress, nil)
        })
    }
}
