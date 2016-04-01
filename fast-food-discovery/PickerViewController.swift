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

    let places = Places.sharedInstance
    var pickerData : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        exploreButton.enabled = false
        
        self.placePicker.delegate = self
        self.placePicker.dataSource = self
        
        populatePicker()
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //NSLog("Value of \(keyPath) changed to \(change![NSKeyValueChangeNewKey]!)")
        
        if(keyPath == "success") {
            populatePicker()
        }
    }
    
    func populatePicker() {
        if(places.success == true && places.types.count > 0) {
            NSLog("Retreived \(places.results.count) results.")
            pickerData = places.types
            placePicker.reloadAllComponents()
            exploreButton.enabled = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "show_detailed" {
            let dest = segue.destinationViewController as! DetailedViewController
            dest.chain = places.types[placePicker.selectedRowInComponent(0)]
        }
    }

}

