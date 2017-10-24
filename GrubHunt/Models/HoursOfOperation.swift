//
//  HoursOfOperation.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/20/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HoursOfOperation: NSManagedObject {
    static let identifier = "HoursOfOperation"
}

extension HoursOfOperation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HoursOfOperation> {
        return NSFetchRequest<HoursOfOperation>(entityName: identifier)
    }

    @NSManaged public var isOpenNow: Bool
    @NSManaged public var type: String?

    // Sub Objects
    @NSManaged public var openTimes: NSSet
}

extension HoursOfOperation {

    func supply(json: JSONDictionary) {
        // Basic Data
        if let type = json["hours_type"] as? String {
            setValue(type, forKey: "type")
        }
        if let isOpenNow = json["is_open_now"] as? Bool {
            setValue(isOpenNow, forKey: "isOpenNow")
        }

        // Child Objects
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedContext = appDelegate.persistentContainer.viewContext

            if let openTimesJSON = json["open"] as? [JSONDictionary] {
                var openTimes = [OpenTime]()
                for openTimeJSON in openTimesJSON {
                    if let entity = NSEntityDescription.entity(forEntityName: OpenTime.identifier, in: managedContext) {
                        let openTime = OpenTime(entity: entity, insertInto: managedContext)
                        openTime.supply(json: openTimeJSON)
                        if self.openTimes.contains(openTime) { continue }
                        openTimes.append(openTime)
                    }
                }
                setValue(NSSet(array: openTimes), forKey: "openTimes")
            }
            appDelegate.saveContext()
        }
    }
}
