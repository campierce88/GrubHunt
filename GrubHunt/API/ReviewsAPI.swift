//
//  ReviewsAPI.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import MapKit

class ReviewsAPI: APIClient {

    internal func getReviews(for business: Business, completion: @escaping ([Review]) -> Void, failure: @escaping FailureBlock) {
        guard let businessId = business.id else { failure(nil, nil); return }
        let url = requestUrl(for: BusinessUrl + "/\(businessId)" + ReviewsUrl)

        super.sendRequest(withURL: url, requestMethod: HTTPMethod.get, completion: { json in
            if let responseJSON = json as? JSONDictionary, let reviewsJSON = responseJSON["reviews"] as? [JSONDictionary], let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                var reviews = [Review]()
                let managedContext = appDelegate.persistentContainer.viewContext

                for reviewJSON in reviewsJSON {
                    let creationTime = reviewJSON["time_created"] as? String ?? ""
                    let predicate = NSPredicate(format: "creationTime = '\(creationTime)'")
                    if !business.reviews.filtered(using: predicate).isEmpty { continue }
                    if let entity = NSEntityDescription.entity(forEntityName: Review.identifier, in: managedContext) {
                        let review = Review(entity: entity, insertInto: managedContext)
                        review.supply(json: reviewJSON)
                        review.setValue(business, forKey: "business")
                        reviews.append(review)
                    }
                }
                completion(reviews)
            }
        }) { (response, error) in
            print("error getting reviews results: \(String(describing: error?.localizedDescription))")
            failure(response, error)
        }
    }
}
