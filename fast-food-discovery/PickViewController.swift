//
//  ViewController.swift
//  fast-food-discovery
//
//  Created by Charles Mathews on 3/30/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import UIKit

class PickViewController: UIViewController,  NSURLSessionDelegate, NSURLSessionDownloadDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var placePicker: UIPickerView!
    
    let base = "https://maps.googleapis.com/maps/api/place/textsearch/"
    let format = "json"
    let key = "AIzaSyDsTvS1RyzH7wVbYhqXGM276SWlnRU5-HA"
    let query = "fast+food"
    
    var types : [String] = []
    var pickerData : [String] = []

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

        self.placePicker.delegate = self
        self.placePicker.dataSource = self
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
                if types.contains(place.name) != true {
                    types.append(place.name)
                }
            }
            
            pickerData = types
            placePicker.reloadAllComponents()

        } catch {
            NSLog("Bad s***?")
        }
    }
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}

