//
//  ViewController.swift
//  fast-food-discovery
//
//  Created by Charles Mathews on 3/30/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import UIKit

class PlacePickViewController: UIViewController,  NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    let base = "https://maps.googleapis.com/maps/api/place/textsearch/"
    let format = "json"
    let key = "AIzaSyDsTvS1RyzH7wVbYhqXGM276SWlnRU5-HA"
    let query = "fast+food"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let location = "16127"
        let built = "\(base)\(format)?query=\(query)+near+\(location)&key=\(key)"
        let url = NSURL(string: built)
        
        NSLog(built)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = ["Accept" : "Application/json"]
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.downloadTaskWithURL(url!) // : NSURLSessionDownloadTask
        
        task.resume()

    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    
    let log : String = String(totalBytesWritten)+"/"+String(totalBytesExpectedToWrite)
    NSLog(log)
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let data = NSData(contentsOfURL: location)!
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.downloadComplete(data)
        })
    }
    
    func downloadComplete(data : NSData) {
        
        NSLog("COMPLETE")
        do {
            let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
            
            var places : [Place] = []
            
            for p in jsonData["results"] as! Array<AnyObject> {
                let place = Place()
                
                for (name, value) in p as! Dictionary<String, AnyObject> {
                    if place.respondsToSelector(Selector(name)) && !NSObject.respondsToSelector(Selector(name)) {
                        place.setValue(value, forKey: name)
                    }
                }
                
                places.append(place)
            }
            
            for place in places {
                NSLog("\(place.name)")
            }

        } catch {
            NSLog("Bad s***")
        }
    }


     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}

