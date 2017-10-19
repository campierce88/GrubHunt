//
//  User.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {
    static let identifier = "User"
}

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: identifier)
    }

    @NSManaged public var name: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var review: Review?
}

extension User {

    func supply(json: JSONDictionary) {
        if let name = json["name"] as? String {
            self.name = name
        }
        if let imageUrl = json["image_url"] as? String {
            self.imageUrl = imageUrl
        }
    }
}

