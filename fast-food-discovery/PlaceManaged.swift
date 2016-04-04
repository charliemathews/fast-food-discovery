/*
 Copywrite Grove City College 2016
 Authored by Charlie Mathews & Sarah Burgess
 */

import Foundation
import CoreData

class PlaceManaged : NSManagedObject {
    @NSManaged var name : String
    @NSManaged var formatted_address : String
    @NSManaged var lat : Double
    @NSManaged var lng : Double
}