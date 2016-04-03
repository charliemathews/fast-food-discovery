/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

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