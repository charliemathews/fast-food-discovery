/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

// need to implement url encoding properly
// http://stackoverflow.com/questions/24879659/how-to-encode-a-url-in-swift


import UIKit
import MapKit

class DetailedViewController: UIViewController, UICollectionViewDelegate {
    
    //@IBOutlet weak var placeDesc: UITextView!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var imgCollection: UICollectionView!
    
    let places = PlaceRepository.sharedInstance
    let images = ImageRepository()
    var watchList : [String] = ["success"]
    let options = NSKeyValueObservingOptions([.New, .Old])
    var chain = ""
    
    private let reuseIdentifier = "FlickrCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places.clearResults()
        loadObservers()
        places.textSearch(places.lat, lng: places.lng, query: chain)
        images.textSearch(chain)
        
        self.imgCollection!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //placeDesc.layer.cornerRadius = 10.0
        //placeDesc.layer.borderWidth = 1
        //placeDesc.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.1).CGColor
        placeTitle.text = chain
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.results.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCell
        
        //view.contentMode = .ScaleAspectFit
        //view.image = UIImage(data: data)
        
        /*
        if(images.results[indexPath.row].data != NSData()) {
            cell.thumb.image = UIImage(data: images.results[indexPath.row].data)
        }*/
 
        
        return cell
    }
    
    func loadObservers() {
        for w in watchList {
            //NSLog("Adding observer for \"places.\(w)\".")
            places.addObserver(self, forKeyPath: w, options: options, context: nil)
        }
        images.addObserver(self, forKeyPath: "loaded", options: options, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //NSLog("Value of \(keyPath) changed to \(change![NSKeyValueChangeNewKey]!)")
        
        if(keyPath == "success" && places.success == true) {
            NSLog("Retreived \(places.results.count) results for \"\(chain)\".")
            
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
        
        if(keyPath == "loaded" && images.loaded == true && images.results.count >= 5) {
            for i in images.results{
                loadImage(i)
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func loadImage(img : Image) {
        var url = "https://farm" + String(img.farm)
        url += ".staticflickr.com/"+img.server
        url += "/"+img.id+"_"+img.secret+"_s.jpg"
        
        NSLog(url)
    
        if let checkedUrl = NSURL(string: url) {
            getDataFromUrl(checkedUrl) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let d = data where error == nil else { return }
                    img.data = d
                    self.imgCollection.reloadSections(NSIndexSet(index: 0))
                }
            }
        }
    }
    
    deinit {
        for w in watchList {
            places.removeObserver(self, forKeyPath: w, context: nil)
        }
        images.removeObserver(self, forKeyPath: "loaded", context: nil)
    }
    
}

