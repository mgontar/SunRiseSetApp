//
//  Date+Utils.swift
//  SunRiseSet
//
//  Created by Admin on 12/17/18.
//  Copyright © 2018 Maksym Gontar. All rights reserved.
//

import Foundation


extension Date {
    func toLocalString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
}
