/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

// need to implement url encoding properly
// http://stackoverflow.com/questions/24879659/how-to-encode-a-url-in-swift


import UIKit
import MapKit

class DetailedViewController: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet weak var placeDesc: UITextView!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    let places = PlaceRepository.sharedInstance
    var watchList : [String] = ["success"]
    let options = NSKeyValueObservingOptions([.New, .Old])
    var chain = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let encodedChain = chain.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        places.clearResults()
        loadObservers()
        places.textSearch(places.lat, lng: places.lng, query: encodedChain)
        
        placeDesc.layer.cornerRadius = 10.0
        placeDesc.layer.borderWidth = 1
        placeDesc.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.1).CGColor
        placeTitle.text = chain
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
            NSLog("Retreived \(places.results.count) results for \"\(chain)\".")
            
            /*
            for place in places.results {
                NSLog("\(place.name) at [\(place.lat),\(place.lng)] with address \(place.formatted_address)")
            }
            */
            
            if(places.results.count > 0) {
                
                let loc = CLLocationCoordinate2D(latitude: places.lat, longitude: places.lng)
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

