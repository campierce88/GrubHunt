//
//  BusinessAPI.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import MapKit

class BusinessAPI: APIClient {

    internal func getBusinessDetails(for businessId: String, completion: @escaping (Business) -> Void, failure: @escaping FailureBlock) {
        let url = requestUrl(for: BusinessUrl + "/\(businessId)")

        super.sendRequest(withURL: url, requestMethod: HTTPMethod.get, completion: { json in
            if let responseJSON = json as? JSONDictionary, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedContext = appDelegate.persistentContainer.viewContext

                let fetchRequest: NSFetchRequest<Business> = Business.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id = '\(businessId)'")
                do {
                    let businesses = try managedContext.fetch(fetchRequest)
                    guard let business = businesses.first else { throw CoreDataError.notFound }
                    business.supply(json: responseJSON)
                    appDelegate.saveContext()
                    completion(business)
                    return
                } catch {
                    if let entity = NSEntityDescription.entity(forEntityName: Business.identifier, in: managedContext) {
                        let business = Business(entity: entity, insertInto: managedContext)
                        business.supply(json: responseJSON)
                        appDelegate.saveContext()
                        completion(business)
                        return
                    }
                }
                
                failure(nil, nil)
            }
        }) { (response, error) in
            print("error getting business details: \(String(describing: error?.localizedDescription))")
            failure(response, error)
        }
    }
}

