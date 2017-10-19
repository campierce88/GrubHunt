//
//  Review.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Review: NSManagedObject {
    static let identifier = "Review"
}

extension Review {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Review> {
        return NSFetchRequest<Review>(entityName: identifier)
    }

    @NSManaged public var url: String?
    @NSManaged public var rating: Float
    @NSManaged public var text: String?
    @NSManaged public var user: User?
    @NSManaged public var creationTime: String?
    @NSManaged public var business: Business?
}

extension Review {

    func supply(json: JSONDictionary) {
        // Basic Data
        if let text = json["text"] as? String {
            setValue(text, forKey: "text")
        }
        if let rating = json["rating"] as? Float {
            setValue(rating, forKey: "rating")
        }
        if let url = json["url"] as? String {
            setValue(url, forKey: "url")
        }
        if let creationTime = json["time_created"] as? String {
            setValue(creationTime, forKey: "creationTime")
        }

        // Child Objects
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedContext = appDelegate.persistentContainer.viewContext
            if let userJSON = json["user"] as? JSONDictionary, let entity = NSEntityDescription.entity(forEntityName: User.identifier, in: managedContext) {
                let user = User(entity: entity, insertInto: managedContext)
                user.supply(json: userJSON)
                setValue(user, forKey: "user")
            }
            appDelegate.saveContext()
        }
    }
}
