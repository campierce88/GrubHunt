//
//  Category.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/20/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Category: NSManagedObject {
    static let identifier = "Category"
}

extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: identifier)
    }

    @NSManaged public var alias: String?
    @NSManaged public var title: String?
}

extension Category {

    func supply(json: JSONDictionary) {
        // Basic Data
        if let alias = json["alias"] as? String {
            setValue(alias, forKey: "alias")
        }
        if let title = json["title"] as? String {
            setValue(title, forKey: "title")
        }
    }
}
