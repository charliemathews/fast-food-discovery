/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

import Foundation
import CoreData

class Image: NSObject {
    var farm    : Int = 0
    var id      : String = ""
    var server  : String = ""
    var secret  : String = ""
    var data    : NSData = NSData()
}