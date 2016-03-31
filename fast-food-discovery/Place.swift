//
//  Place.swift
//  fast-food-discovery
//
//  Created by Charles Mathews on 3/30/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import Foundation

class Place : NSObject {
    
    var name : String
    var formatted_address : String
    var lat : Double
    var lng : Double
    
    override init() {
        name = ""
        formatted_address = ""
        lat = 0
        lng = 0
        super.init()
    }
    
}