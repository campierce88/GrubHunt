//
//  Business.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Business: NSManagedObject {
    static let identifier = "Business"
}

extension Business {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Business> {
        return NSFetchRequest<Business>(entityName: identifier)
    }

    @NSManaged public var id: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var isClosed: Bool
    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var photos: [String]?
    @NSManaged public var price: String?
    @NSManaged public var rating: Float
    @NSManaged public var reviewCount: Int64

    // Sub Objects
    @NSManaged public var address: Location?
    @NSManaged public var categories: NSSet
    @NSManaged public var coordinates: Coordinates?
    @NSManaged public var hoursOfOperation: NSSet
    @NSManaged public var reviews: NSSet
}

extension Business {

    func supply(json: JSONDictionary) {
        // Basic Data
        if let id = json["id"] as? String {
            setValue(id, forKey: "id")
        }
        if let imageUrl = json["image_url"] as? String {
            setValue(imageUrl, forKey: "imageUrl")
        }
        if let isClosed = json["is_closed"] as? Bool {
            setValue(isClosed, forKey: "isClosed")
        }
        if let name = json["name"] as? String {
            setValue(name, forKey: "name")
        }
        if let phoneNumber = json["phone"] as? String {
            setValue(phoneNumber, forKey: "phoneNumber")
        }
        if let photos = json["photos"] as? [String] {
            setValue(photos, forKey: "photos")
        }
        if let price = json["price"] as? String {
            setValue(price, forKey: "price")
        }
        if let rating = json["rating"] as? Float {
            setValue(rating, forKey: "rating")
        }
        if let reviewCount = json["review_count"] as? Int64 {
            setValue(reviewCount, forKey: "reviewCount")
        }

        // Child Objects
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedContext = appDelegate.persistentContainer.viewContext

            if let addressJSON = json["location"] as? JSONDictionary {
                if let entity = NSEntityDescription.entity(forEntityName: Location.identifier, in: managedContext) {
                    let address = Location(entity: entity, insertInto: managedContext)
                    address.supply(json: addressJSON)
                    setValue(address, forKey: "address")
                }
            }
            
            if let coordinatesJSON = json["coordinates"] as? JSONDictionary {
                if let entity = NSEntityDescription.entity(forEntityName: Coordinates.identifier, in: managedContext) {
                    let coordinates = Coordinates(entity: entity, insertInto: managedContext)
                    coordinates.supply(json: coordinatesJSON)
                    setValue(coordinates, forKey: "coordinates")
                }
            }
            
            if let reviewsJSON = json["reviews"] as? [JSONDictionary] {
                var reviews = [Review]()
                for reviewJSON in reviewsJSON {
                    if let entity = NSEntityDescription.entity(forEntityName: Review.identifier, in: managedContext) {
                        let review = Review(entity: entity, insertInto: managedContext)
                        review.supply(json: reviewJSON)
                        if self.reviews.contains(review) { continue }
                        reviews.append(review)
                    }
                }
                setValue(NSSet(array: reviews), forKey: "reviews")
            }

            if let categoriesJSON = json["categories"] as? [JSONDictionary] {
                var categories = [Category]()
                for categoryJSON in categoriesJSON {
                    if let entity = NSEntityDescription.entity(forEntityName: Category.identifier, in: managedContext) {
                        let category = Category(entity: entity, insertInto: managedContext)
                        category.supply(json: categoryJSON)
                        if self.categories.contains(category) { continue }
                        categories.append(category)
                    }
                }
                setValue(NSSet(array: categories), forKey: "categories")
            }

            if let hoursJSON = json["hours"] as? [JSONDictionary] {
                var hours = [HoursOfOperation]()
                for hourJSON in hoursJSON {
                    if let entity = NSEntityDescription.entity(forEntityName: HoursOfOperation.identifier, in: managedContext) {
                        let hour = HoursOfOperation(entity: entity, insertInto: managedContext)
                        hour.supply(json: hourJSON)
                        if self.hoursOfOperation.contains(hour) { continue }
                        hours.append(hour)
                    }
                }
                setValue(NSSet(array: hours), forKey: "hoursOfOperation")
            }
            
            appDelegate.saveContext()
        }
    }
}

