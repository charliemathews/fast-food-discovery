/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

// example query for reference
// https://maps.googleapis.com/maps/api/place/textsearch/json?query=unique+fast+food+near+16127&key=AIzaSyDsTvS1RyzH7wVbYhqXGM276SWlnRU5-HA

import Foundation

class Places {
    
    let base = "https://maps.googleapis.com/maps/api/place/"
    let format = "json"
    let key = "AIzaSyDsTvS1RyzH7wVbYhqXGM276SWlnRU5-HA"
    
    var results : [Place] = []
    
    init() {
        
    }
    
    func getPlacesTextQuery(query : String, location : String) {
    
        //build query
        var queryURL : String = base
        queryURL += "textsearch/"
        queryURL += format
        queryURL += "?query=" + query + "+near+" + location
        queryURL += "&key=" + key
        
        
    }
}