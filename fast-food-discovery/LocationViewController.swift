//
//  LocationViewController.swift
//  fast-food-discovery
//
//  Created by Charles Mathews on 3/31/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    var lat : Double = 0
    var lng : Double = 0
    let places = Places.sharedInstance
    
    var watchList : [String] = ["success"]
    let options = NSKeyValueObservingOptions([.New, .Old])
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var statusText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places.clear()
        loadObservers()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        spinner.alpha = 1.0
        spinner.startAnimating()
        statusText.text = "Acquiring location."
        
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            NSLog("Found user's location: \(location)")
            
            lat = location.coordinate.latitude
            lng = location.coordinate.longitude
            
            places.lat = lat
            places.lng = lng
            
            statusText.text = "\(lat),\(lng)"
            
            let loc = "\(lat),\(lng)"
            places.textSearch(loc, query: "fast+food")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Failed to find user's location: \(error.localizedDescription)")
        
        lat = 41.1578376
        lng = -80.0886702
        
        places.lat = lat
        places.lng = lng
        
        statusText.text = "Failed to get location. Using default."
        spinner.alpha = 0.0
        
        let loc = "\(lat),\(lng)"
        places.textSearch(loc, query: "fast+food")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if(keyPath == "success" && places.success == true) {
            statusText.text = "Fast food chains found!"
            performSegueWithIdentifier("postLoad", sender: self)
        }
    }
    
    func loadObservers() {
        for w in watchList {
            places.addObserver(self, forKeyPath: w, options: options, context: nil)
        }
    }
    
    deinit {
        for w in watchList {
            places.removeObserver(self, forKeyPath: w, context: nil)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "postLoad" {
        }
    }
    

}
