//
//  WebAPI.swift
//  SunRiseSet
//
//  Created by Admin on 12/17/18.
//  Copyright © 2018 Maksym Gontar. All rights reserved.
//

import CoreLocation

class WebAPI {
    
    static let baseUrl = "https://api.sunrise-sunset.org/"
    
    enum EndPoint: String {
        case allImages = "json?lat=%f&lng=%f&formatted=0"
    }

    class func getSunInfoForCoordinate(_ coordinate:CLLocationCoordinate2D, completionHandler: @escaping (SunInfo.Results?, Error?) -> Void){
        let jsonUrlString = baseUrl + String(format: EndPoint.allImages.rawValue, coordinate.latitude, coordinate.longitude)
        
        guard let url = URL(string: jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else {
                completionHandler(nil, CustomError.appError)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(SunInfo.self, from: data)
                
                switch result.status {
                case .OK:
                    completionHandler(result.results, nil)
                case .INVALID_REQUEST:
                    completionHandler(nil, CustomError.serviceError)
                case .INVALID_DATE:
                    completionHandler(nil, CustomError.serviceError)
                case .UNKNOWN_ERROR:
                    completionHandler(nil, CustomError.serviceError)
                }
            }catch _ {
                completionHandler(nil, CustomError.parsingError)
            }
            
            }.resume()
    }
}
