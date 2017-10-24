//
//  SearchTerm.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import CoreData

class SearchTerm: NSManagedObject {
    static let identifier = "SearchTerm"
}

extension SearchTerm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchTerm> {
        return NSFetchRequest<SearchTerm>(entityName: identifier)
    }
    
    @NSManaged public var term: String?
    @NSManaged public var totalResults: Int64
    @NSManaged public var coordinates: Coordinates?
}
