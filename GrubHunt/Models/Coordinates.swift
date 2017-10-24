//
//  Coordinates.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/20/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Coordinates: NSManagedObject {
    static let identifier = "Coordinates"
}

extension Coordinates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coordinates> {
        return NSFetchRequest<Coordinates>(entityName: identifier)
    }

    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
}

extension Coordinates {

    func supply(json: JSONDictionary) {
        // Basic Data
        if let latitude = json["latitude"] as? Float {
            setValue(latitude, forKey: "latitude")
        }
        if let logitude = json["longitude"] as? Float {
            setValue(logitude, forKey: "longitude")
        }
    }
}
