/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

// example query for reference
// https://maps.googleapis.com/maps/api/place/textsearch/json?query=unique+fast+food+near+16127&key=AIzaSyDsTvS1RyzH7wVbYhqXGM276SWlnRU5-HA

import UIKit
import Foundation
import CoreData

final class PlaceRepository : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    let base = "https://maps.googleapis.com/maps/api/place/"
    let format = "json"
    let key = "AIzaSyDsTvS1RyzH7wVbYhqXGM276SWlnRU5-HA"
    
    var results : [Place] = []
    dynamic var types : [String] = []
    dynamic var success : Bool = false
    var progress : Float = 0.0
    
    var lat : Double = 0
    var lng : Double = 0
    
    static let sharedInstance = PlaceRepository()
    
    private override init() {
        
    }
    
    func clear() {
        types = []
        clearResults()
    }
    
    func clearResults() {
        results = []
        success = false
        progress = 0.0
    }
    
    func getTypes() -> [String] {
        for place in results {
            if types.contains(place.name) != true {
                types.append(place.name)
            }
        }
        return types
    }
    
    func executeQuery(url : String) {
        
        NSLog(url)
        
        success = false
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = ["Accept" : "Application/json"]
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.downloadTaskWithURL(NSURL(string: url)!)
        task.resume()
    }
    
    func nearbySearch(location: String) {
        
        var built = base
        built += "nearbysearch/"
        built += format
        built += "?key=\(key)"
        built += "&location=\(location)"
        built += "&radius=8000"
        
        //meal_takeaway
        //restaurant
        built += "&type=meal_takeaway"
        
        executeQuery(built)
    }
    
    func radiusSearch(location: String) {
        
        var built = base
        built += "radarsearch/"
        built += format
        
        built += "?key=\(key)"
        built += "&location=\(location)"
        built += "&radius=8000"
        built += "&type=food"
        
        executeQuery(built)
    }
    
    func textSearch(lat : Double, lng : Double, query : String) {
        
        let escapedQuery = query.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        self.lat = lat
        self.lng = lng
        
        let loc = "\(lat),\(lng)"
        
        var built = base
        built += "textsearch/"
        built += format
        
        built += "?key=" + key
        built += "&location=" + loc
        built += "&radius=8000"
        built += "&query=\(escapedQuery)"
        
        executeQuery(built)
    }
    
    // Download in progress.
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let log : String = "Downloading places..." + String(totalBytesWritten) + "/" + String(totalBytesExpectedToWrite) + " bytes"
        
        progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        
        NSLog(log)
    }
    
    // Download complete.
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let data = NSData(contentsOfURL: location)!
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.downloadComplete(data)
        })
    }
    
    func downloadComplete(data : NSData) {
        
        NSLog("Place query completed.")
        do {
            let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
            
            for p in jsonData["results"] as! Array<AnyObject> {
                let place = Place()
                
                for (name, value) in p as! Dictionary<String, AnyObject> {
                    if place.respondsToSelector(Selector(name)) && !NSObject.respondsToSelector(Selector(name)) {
                        place.setValue(value, forKey: name)
                    }
                }
                
                if let geo = p["geometry"] as? Dictionary<String, AnyObject> {
                    if let loc = geo["location"] as? Dictionary<String, AnyObject> {
                        
                        for (name, value) in loc {
                            if place.respondsToSelector(Selector(name)) && !NSObject.respondsToSelector(Selector(name)) {
                                place.setValue(value, forKey: name)
                            }
                        }
                        
                    }
                }
                
                results.append(place)
            }
            
            if results.count > 0 {
                success = true
            }
        } catch {
            NSLog("JSON serialization failed!")
        }
    }
    
    func add(p : Place) {
        results.append(p)
    }
    
}