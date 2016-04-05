/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

import UIKit
import CoreLocation
import CoreData

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    let defaults : NSUserDefaults = NSUserDefaults()
    var lat : Double = 0
    var lng : Double = 0
    let places = PlaceRepository.sharedInstance
    var hasMoved : Bool = false
    
    var watchList : [String] = ["success"]
    let options = NSKeyValueObservingOptions([.New, .Old])
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var statusText: UILabel!
    
    let pi = 3.14159265358979323846
    let earthRadiusKm = 6371.0
    
    let moc = DataController.instance.managedObjectContext
    
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

            getNearbyPlaces()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Failed to find user's location: \(error.localizedDescription)")
        
        lat = 41.192632 //defaults.doubleForKey("lat")
        lng = -80.075843 //defaults.doubleForKey("lng")
        
        getNearbyPlaces()
    }
    
    func deg2rad(deg: Double) -> Double {
        return (deg * pi / 180)
    }
    
    func rad2deg(rad: Double) -> Double {
        return (rad * 180 / pi)
    }
    
    // return the distance between two coordinates in km
    func getDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        
        let lat1r = deg2rad(lat1)
        let lon1r = deg2rad(lng1)
        let lat2r = deg2rad(lat2)
        let lon2r = deg2rad(lng2)
        let u = sin((lat2r - lat1r)/2)
        let v = sin((lon2r - lon1r)/2)
        return 2.0 * earthRadiusKm * asin(sqrt(u * u + cos(lat1r) * cos(lat2r) * v * v))
    }
    
    func getNearbyPlaces() {
        
        // if user moved
        if getDistance(lat, lng1: lng, lat2: defaults.doubleForKey("lat"), lng2: defaults.doubleForKey("lng")) > 1 {
            
            NSLog("User is in a new location! Pulling new results from google.")
            
            hasMoved = true
            
            defaults.setDouble(lat, forKey: "lat")
            defaults.setDouble(lng, forKey: "lng")

            statusText.text = "Searching for fast food chains."
        
            // Delete places from core data.
            let fetchRequest = NSFetchRequest(entityName: DataController.instance.data_entity as String)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
            do {
                NSLog("Deleting old results from core data.")
                try moc.executeRequest(deleteRequest)
                try moc.save()
            } catch {
                print (error)
            }
        
            // pull new results
            places.textSearch(lat, lng: lng, query: "fast+food")
        
        } else { // if user has not moved
            
            NSLog("User has not moved. Preparing to load results from core data.")
            
            let fetchRequest = NSFetchRequest(entityName: DataController.instance.data_entity)
            
            places.lat = defaults.doubleForKey("lat")
            places.lng = defaults.doubleForKey("lng")
        
            do {
                let results =
                    try moc.executeFetchRequest(fetchRequest) as! [PlaceManaged] //[NSManagedObject]
                
                for r in results {
                    let place : Place = Place()
                    
                    place.formatted_address = r.formatted_address
                    place.lat = r.lat
                    place.lng = r.lng
                    place.name = r.name
                    
                    places.add(place)
                }
                
                if(places.results.count > 0) {
                    NSLog("Sucessfully pulled stored results from core data.")
                    places.success = true
                }
                
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if(keyPath == "success" && places.success == true) {
            
            statusText.text = "Fast food chains found!"
            removeObservers()
            
            
            // ADD PLACES TO CORE DATA
            if hasMoved == true {
                for p in places.results {
                    let managedPlace = NSEntityDescription.insertNewObjectForEntityForName(DataController.instance.data_entity, inManagedObjectContext: moc) as! PlaceManaged
                
                    managedPlace.setValue(p.formatted_address, forKey: "formatted_address")
                    managedPlace.setValue(p.lat, forKey: "lat")
                    managedPlace.setValue(p.lng, forKey: "lng")
                    managedPlace.setValue(p.name, forKey: "name")
                }
            
                do {
                    try moc.save()
                    NSLog("Saving places to core data.")
                } catch let error as NSError {
                    NSLog("Failed to save to core data (\(error))")
                }
            }
            
            performSegueWithIdentifier("postLoad", sender: self)
        }
    }
    
    func loadObservers() {
        for w in watchList {
            places.addObserver(self, forKeyPath: w, options: options, context: nil)
        }
    }
    
    func removeObservers() {
        for w in watchList {
            places.removeObserver(self, forKeyPath: w, context: nil)
        }
        watchList = []
    }
    
    deinit {
        removeObservers()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "postLoad" {
        }
    }
    

}
