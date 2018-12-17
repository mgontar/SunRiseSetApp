//
//  SunInfo.swift
//  SunRiseSet
//
//  Created by Admin on 12/17/18.
//  Copyright © 2018 Maksym Gontar. All rights reserved.
//

import Foundation

struct SunInfo: Decodable {
    
    enum Status: String, Decodable {
        //indicates that no errors occurred
        case OK = "OK"
        //indicates that either lat or lng parameters are missing or invalid
        case INVALID_REQUEST = "INVALID_REQUEST"
        //indicates that date parameter is missing or invalid
        case INVALID_DATE = "INVALID_DATE"
        //indicates that the request could not be processed due to a server error. The request may succeed if you try again
        case UNKNOWN_ERROR = "UNKNOWN_ERROR"
    }
    
    let status: Status
    let results: Results
    
    enum CodingKeys:String, Swift.CodingKey {
        case status = "status"
        case results = "results"
    }
    
    struct Results: Decodable {
        let sunrise: Date
        let sunset: Date
        let solarNoon: Date
        let dayLenght: Int
        let civilTwilightBegin: Date
        let civilTwilightEnd: Date
        let nauticalTwilightBegin: Date
        let nauticalTwilightEnd: Date
        let astronomicalTwilightBegin: Date
        let astronomicalTwilightEnd: Date
        
        enum CodingKeys:String, Swift.CodingKey {
            case sunrise = "sunrise"
            case sunset = "sunset"
            case solarNoon = "solar_noon"
            case dayLenght = "day_length"
            case civilTwilightBegin = "civil_twilight_begin"
            case civilTwilightEnd = "civil_twilight_end"
            case nauticalTwilightBegin = "nautical_twilight_begin"
            case nauticalTwilightEnd = "nautical_twilight_end"
            case astronomicalTwilightBegin = "astronomical_twilight_begin"
            case astronomicalTwilightEnd = "astronomical_twilight_end"
        }
    }
}

extension SunInfo {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decode(Status.self, forKey: .status)
        results = try values.decode(Results.self, forKey: .results)
    }
}

extension SunInfo.Results {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sunrise = try values.decode(Date.self, forKey: .sunrise)
        sunset = try values.decode(Date.self, forKey: .sunset)
        solarNoon = try values.decode(Date.self, forKey: .solarNoon)
        dayLenght = try values.decode(Int.self, forKey: .dayLenght)
        civilTwilightBegin = try values.decode(Date.self, forKey: .civilTwilightBegin)
        civilTwilightEnd = try values.decode(Date.self, forKey: .civilTwilightEnd)
        nauticalTwilightBegin = try values.decode(Date.self, forKey: .nauticalTwilightBegin)
        nauticalTwilightEnd = try values.decode(Date.self, forKey: .nauticalTwilightEnd)
        astronomicalTwilightBegin = try values.decode(Date.self, forKey: .astronomicalTwilightBegin)
        astronomicalTwilightEnd = try values.decode(Date.self, forKey: .astronomicalTwilightEnd)
    }
}
