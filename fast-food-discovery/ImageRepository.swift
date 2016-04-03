/*
Copywrite Grove City College 2016
Authored by Charlie Mathews & Sarah Burgess
*/

import Foundation

class ImageRepository : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    let format = "json&nojsoncallback"
    let key = "5e65e893e59dfda27d321b13c89b8899"
    
    var results : [Image] = []
    dynamic var types : [String] = []
    dynamic var loaded : Bool = false
    
    override init() {
        
    }
    
    func executeQuery(url : String) {
        
        loaded = false
        NSLog(url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = ["Accept" : "Application/json"]
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.downloadTaskWithURL(NSURL(string: url)!)
        task.resume()
    }
    
    func textSearch(searchTerm:String) {
        
        let escapedTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let URLString = base+"&api_key=\(key)&text=\(escapedTerm)&per_page=20&format=json&nojsoncallback=1"
        executeQuery(URLString)
    }
    
    // Download in progress.
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let log : String = "Downloading image results..." + String(totalBytesWritten) + "/" + String(totalBytesExpectedToWrite)
        NSLog(log)
    }
    
    // Download complete.
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let data = NSData(contentsOfURL: location)!
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.downloadComplete(data)
        })
    }
    
    func downloadComplete(data : NSData) {
        
        NSLog("Image query completed.")
        do {
            let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
            
            for p in jsonData["photos"]!["photo"] as! Array<AnyObject> {
                let im = Image()
                for(name,value) in p as! Dictionary<String,AnyObject> {
                    if (im.respondsToSelector(Selector(name)) && !NSObject.respondsToSelector(Selector(name))) {
                        im.setValue(value,forKey:name)
                    }
                }
                //NSLog("\(im.farm) \(im.id) \(im.secret) \(im.server)")
                results.append(im)
            }
            
            NSLog("Retreived \(results.count) image results.")
            loaded = true
        } catch {
            NSLog("JSON serialization failed!")
        }
    }
    
}