/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

// need to implement url encoding properly
// http://stackoverflow.com/questions/24879659/how-to-encode-a-url-in-swift


import UIKit
import MapKit

class DetailedViewController: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    let places = Places()
    var watchList : [String] = ["success"]
    let options = NSKeyValueObservingOptions([.New, .Old])
    var chain = ""
    var location = ""
    let lat : Double = 0
    let lon : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController!.navigationBar.topItem!.title = chain
        let encodedChain = chain.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        loadObservers()
        places.fetchTextSearch(encodedChain, location: location)
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
        
        NSLog("Value of \(keyPath) changed to \(change![NSKeyValueChangeNewKey]!)")
        
        if(keyPath == "success" && places.success == true) {
            NSLog("Retreived \(places.results.count) results.")
            
            for place in places.results {
                NSLog("\(place.name) at [\(place.lat),\(place.lng)] with address \(place.formatted_address)")
            }
            
            if(places.results.count > 0) {
                
                let loc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                let reg = MKCoordinateRegion(center: loc, span: span)
                map.setRegion(reg, animated: false)
                
                for p in places.results {
                    let pin = MKPointAnnotation()
                    pin.coordinate = CLLocationCoordinate2D(latitude: p.lat, longitude: p.lng)
                    map.addAnnotation(pin)
                }
                
                map.showAnnotations(map.annotations, animated: true)
            }
        }
    }
    
    deinit {
        for w in watchList {
            places.removeObserver(self, forKeyPath: w, context: nil)
        }
    }
    
}

