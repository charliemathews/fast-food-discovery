/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
*/


// example query for reference
// https://maps.googleapis.com/maps/api/place/textsearch/json?query=unique+fast+food+near+16127&key=AIzaSyDsTvS1RyzH7wVbYhqXGM276SWlnRU5-HA

// API documentation
// https://developers.google.com/places/web-service/search#RadarSearchRequests


import UIKit
import CoreLocation

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var placePicker: UIPickerView!
    @IBOutlet weak var exploreButton: UIBarButtonItem!

    let manager = CLLocationManager()
    let places = Places()
    var pickerData : [String] = []
    var watchList : [String] = ["success"]
    let options = NSKeyValueObservingOptions([.New, .Old])
    var loc = "41.1578376,-80.0886702"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        exploreButton.enabled = false
        
        NSLog("Finding location...")
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        
        self.placePicker.delegate = self
        self.placePicker.dataSource = self
        loadObservers()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            NSLog("Found user's location: \(location)")
            
            let loc = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            places.textSearch(loc, query: "fast+food")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Failed to find user's location: \(error.localizedDescription)")
        
        places.textSearch(loc, query: "fast+food")
        places.textSearch(loc, query: "takeout")
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
    
    func loadObservers() {
        for w in watchList {
            //NSLog("Adding observer for \"places.\(w)\".")
            places.addObserver(self, forKeyPath: w, options: options, context: nil)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //NSLog("Value of \(keyPath) changed to \(change![NSKeyValueChangeNewKey]!)")
        
        if(keyPath == "success" && places.success == true) {
            //NSLog("Observer noticed that places updated successfully.")
            //print(places.types)
            pickerData = places.types
            placePicker.reloadAllComponents()
            exploreButton.enabled = true
        }
    }

    deinit {
        for w in watchList {
            places.removeObserver(self, forKeyPath: w, context: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "show_detailed" {
            let dest = segue.destinationViewController as! DetailedViewController
            dest.chain = places.types[placePicker.selectedRowInComponent(0)]
            dest.location = loc
        }
    }

}

