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
    @NSManaged public var rating: Float
    @NSManaged public var name: String?
    @NSManaged public var photos: [String]?
    @NSManaged public var reviews: NSSet
}

extension Business {

    func supply(json: JSONDictionary) {
        // Basic Data
        if let id = json["id"] as? String {
            setValue(id, forKey: "id")
        }
        if let name = json["name"] as? String {
            setValue(name, forKey: "name")
        }
        if let rating = json["rating"] as? Float {
            setValue(rating, forKey: "rating")
        }
        if let imageUrl = json["image_url"] as? String {
            setValue(imageUrl, forKey: "imageUrl")
        }
        if let photos = json["photos"] as? [String] {
            setValue(photos, forKey: "photos")
        }

        // Child Objects
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedContext = appDelegate.persistentContainer.viewContext

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
            appDelegate.saveContext()
        }
    }
}

