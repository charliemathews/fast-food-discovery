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
    
    @IBOutlet weak var restaurantsButton: UIBarButtonItem!
    @IBOutlet weak var textInput: UITextField!
    
    @IBAction func selectTextInput(sender: AnyObject) {
        textInput.becomeFirstResponder()
    }
    
    @IBAction func deselectTextInput(sender: AnyObject) {
        textInput.resignFirstResponder()
    }
    
    @IBAction func findLocation(sender: AnyObject) {
        restaurantsButton.enabled = false
        
        textInput.resignFirstResponder()
        
        manager.requestWhenInUseAuthorization()
        //manager.startUpdatingLocation()
        manager.requestLocation()
        
        textInput.text = "searching..."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places.clear()
        loadObservers()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        restaurantsButton.enabled = false
        textInput.enabled = false
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            NSLog("Found user's location: \(location)")
            
            lat = location.coordinate.latitude
            lng = location.coordinate.longitude
            
            textInput.enabled = false
            textInput.text = "\(lat),\(lng)"
            
            let loc = "\(lat),\(lng)"
            places.textSearch(loc, query: "fast+food")
            //places.textSearch(loc, query: "takeout")
            
            //restaurantsButton.enabled = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Failed to find user's location: \(error.localizedDescription)")
        
        lat = 41.1578376
        lng = -80.0886702
        
        textInput.text = "failed. will use default."
        
        let loc = "\(lat),\(lng)"
        places.textSearch(loc, query: "fast+food")
        //places.textSearch(loc, query: "takeout")
        
        //restaurantsButton.enabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if(keyPath == "success") {
            textInput.text = "Fast food chains found!"
            restaurantsButton.enabled = true
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
        
        if segue.identifier == "show_chains" {
            let dest = segue.destinationViewController as! PickerViewController
            dest.lat = lat
            dest.lng = lng
        }
    }
    

}
