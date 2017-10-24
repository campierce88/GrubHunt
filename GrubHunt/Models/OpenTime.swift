//
//  OpenTime.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/20/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class OpenTime: NSManagedObject {
    static let identifier = "OpenTime"
}

extension OpenTime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OpenTime> {
        return NSFetchRequest<OpenTime>(entityName: identifier)
    }

    @NSManaged public var isOvernight: Bool
    @NSManaged public var start: String?
    @NSManaged public var end: String?
    @NSManaged public var day: Int64
}

extension OpenTime {
    
    func supply(json: JSONDictionary) {
        // Basic Data
        if let isOvernight = json["is_overnight"] as? Bool {
            setValue(isOvernight, forKey: "isOvernight")
        }
        if let start = json["start"] as? String {
            setValue(start, forKey: "start")
        }
        if let end = json["end"] as? String {
            setValue(end, forKey: "end")
        }
        if let day = json["day"] as? Int64 {
            setValue(day, forKey: "day")
        }
    }
}
