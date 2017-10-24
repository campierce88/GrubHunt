//
//  Location.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/20/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Location: NSManagedObject {
    static let identifier = "Location"
}

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: identifier)
    }

    @NSManaged public var addressLine1: String?
    @NSManaged public var addressLine2: String?
    @NSManaged public var addressLine3: String?
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var crossStreets: String?
    @NSManaged public var displayAddress: [String]?
    @NSManaged public var state: String?
    @NSManaged public var zipCode: String?
}

extension Location {

    func supply(json: JSONDictionary) {
        // Basic Data
        if let addressLine1 = json["address1"] as? String {
            setValue(addressLine1, forKey: "addressLine1")
        }
        if let addressLine2 = json["address2"] as? String {
            setValue(addressLine2, forKey: "addressLine2")
        }
        if let addressLine3 = json["address3"] as? String {
            setValue(addressLine3, forKey: "addressLine3")
        }
        if let city = json["city"] as? String {
            setValue(city, forKey: "city")
        }
        if let state = json["state"] as? String {
            setValue(state, forKey: "state")
        }
        if let zipCode = json["zip_code"] as? String {
            setValue(zipCode, forKey: "zipCode")
        }
        if let country = json["country"] as? String {
            setValue(country, forKey: "country")
        }
        if let crossStreets = json["cross_streets"] as? String {
            setValue(crossStreets, forKey: "crossStreets")
        }
        if let displayAddress = json["display_address"] as? [String] {
            setValue(displayAddress, forKey: "displayAddress")
        }
    }
}
