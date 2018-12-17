//
//  PlaceCell.swift
//  SunRiseSet
//
//  Created by Admin on 12/17/18.
//  Copyright © 2018 Maksym Gontar. All rights reserved.
//

import UIKit

class PlaceCell: UITableViewCell {

    static let identifier = "PlaceCell"
    static let nibName = "PlaceCell"
    
    @IBOutlet weak var lbName: UILabel!
    
    @IBOutlet weak var lbSunrise: UILabel!
    
    @IBOutlet weak var lbSunset: UILabel!
    
    var place: Place!
    {
        didSet {
            lbName.text = place.name
            lbSunrise.text = "sunrise: " + (place.sunInfoResults?.sunrise.toLocalString() ?? "unknown")
            lbSunset.text = "sunset " + (place.sunInfoResults?.sunset.toLocalString() ?? "unknown")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
