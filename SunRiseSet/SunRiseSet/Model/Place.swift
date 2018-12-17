//
//  Place.swift
//  SunRiseSet
//
//  Created by Admin on 12/17/18.
//  Copyright © 2018 Maksym Gontar. All rights reserved.
//

import Foundation
import CoreLocation

class Place {
    var coordinate:CLLocationCoordinate2D
    var name:String?
    var date:Date
    var sunInfoResults:SunInfo.Results?
    
    init(coordinate:CLLocationCoordinate2D, name:String? = nil, date:Date = Date(), sunInfoResults: SunInfo.Results? = nil)
    {
        self.coordinate = coordinate
        self.name = name
        self.date = date
        self.sunInfoResults = sunInfoResults
    }
}
