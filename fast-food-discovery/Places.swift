/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

// example query for reference
// https://maps.googleapis.com/maps/api/place/textsearch/json?query=unique+fast+food+near+16127&key=AIzaSyDsTvS1RyzH7wVbYhqXGM276SWlnRU5-HA

import Foundation

class Places : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    let base = "https://maps.googleapis.com/maps/api/place/"
    let format = "json"
    let key = "AIzaSyDsTvS1RyzH7wVbYhqXGM276SWlnRU5-HA"
    
    var results : [Place] = []
    dynamic var types : [String] = []
    dynamic var success : Bool = false
    
    override init() {
        
    }
    
    func executeQuery(url : String) {
        
        success = false
        NSLog(url)
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
    
    func textSearch(location : String, query : String) {
    
        var built = base
        built += "textsearch/"
        built += format
        
        built += "?key=" + key
        built += "&location=" + location
        built += "&radius=8000"
        built += "&query=\(query)"
        
        executeQuery(built)
    }
    
    // Download in progress.
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let log : String = "Downloading..." + String(totalBytesWritten) + "/" + String(totalBytesExpectedToWrite)
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
        
        NSLog("Query completed.")
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
            
            for place in results {
                if types.contains(place.name) != true {
                    types.append(place.name)
                }
            }
            
            NSLog("Found \(results.count) places of \(types.count) types")
            
            if results.count > 0 {
                success = true
            }
        } catch {
            NSLog("JSON serialization failed!")
        }
    }

}