//
//  SearchAPI.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import MapKit

class SearchAPI: APIClient {

    internal func searchBusinesses(with term: String, and location: CLLocation, offset: Int? = nil, completion: @escaping ([Business], Int) -> Void, failure: @escaping FailureBlock) {
        let lat = Double(location.coordinate.latitude)
        let long = Double(location.coordinate.longitude)
        var params = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "latitude", value: "\(lat)"),
            URLQueryItem(name: "longitude", value: "\(long)"),
            URLQueryItem(name: "limit", value: "50"),
        ]
        if let offset = offset {
            params.append(URLQueryItem(name: "offset", value: "\(offset)"))
        }
        let url = requestUrl(for: SearchUrl, withQueryParams: params)

        super.sendRequest(withURL: url, requestMethod: HTTPMethod.get, completion: { json in
            if let responseJSON = json as? JSONDictionary, let businessesJSON = responseJSON["businesses"] as? [JSONDictionary], let total = responseJSON["total"] as? Int, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                var businesses = [Business]()
                let managedContext = appDelegate.persistentContainer.viewContext
                
                for businessJSON in businessesJSON {
                    if let entity = NSEntityDescription.entity(forEntityName: Business.identifier, in: managedContext) {
                        let business = Business(entity: entity, insertInto: managedContext)
                        business.supply(json: businessJSON)
                        businesses.append(business)
                    }
                }
                completion(businesses, total)
            } 
        }) { (response, error) in
            print("error getting business search results: \(String(describing: error?.localizedDescription))")
            failure(response, error)
        }
    }
}
