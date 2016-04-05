/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

import UIKit
import CoreLocation
import CoreData

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    var lat : Double = 0
    var lng : Double = 0
    let places = PlaceRepository.sharedInstance
    
    var watchList : [String] = ["success"]
    let options = NSKeyValueObservingOptions([.New, .Old])
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var statusText: UILabel!
    
    let moc = DataController.instance.managedObjectContext
    
    /*
    lazy var psc: NSPersistentStoreCoordinator = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
     */
    
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
        
        lat = 41.1578376
        lng = -80.0886702
        
        getNearbyPlaces()
    }
    
    func getNearbyPlaces() {
        
    // if location > 1 mile from old location
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
        
        // Pull new results.
        places.textSearch(lat, lng: lng, query: "fast+food")

        
    // else
        
        // LOAD PLACES FROM CORE DATA
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if(keyPath == "success" && places.success == true) {
            statusText.text = "Fast food chains found!"
            removeObservers()
            
            
            // ADD PLACES TO CORE DATA
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
