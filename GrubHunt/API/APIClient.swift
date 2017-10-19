//
//  APIClient.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/16/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation
import Alamofire

public typealias CompletionBlock = (JSONObject?) -> Void
public typealias FailureBlock = (URLResponse?, Error?) -> Void
public typealias ProgressBlock = (Float) -> Void

struct APIError: Error {
    let message: String
    let code: String
}

enum CoreDataError: Error {
    case notFound
}

public class APIClient: NSObject {
    
    class var swiftSharedInstance: APIClient {
        struct Singleton {
            static let instance = APIClient()
        }
        return Singleton.instance
    }
    
    class var shared: APIClient {
        get {
            return APIClient.swiftSharedInstance
        }
    }
    
    private static let clientId = "xq4QVo7OJy08jMNaOzUx9w"
    private static let clientSecret = "V3nb3tefk2LfGGg2naiVbDzX2uKSM96MCasFlJGTIeqZBo27PK5jYxDJYP01FfmW"

    var urlComponents: URLComponents {
        get {
            var components = URLComponents()
            components.scheme = "https"
            components.host = apiBaseUrl
            return components
        }
    }
    
    var apiToken: String? {
        get {
            return UserDefaults.standard.object(forKey: "apiToken") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "apiToken")
        }
    }
    
    func requestUrl(for endpoint: String, withQueryParams params: [URLQueryItem]? = nil) -> URL {
        var urlComponents = self.urlComponents
        urlComponents.path = endpoint
        urlComponents.queryItems = params
        return urlComponents.url!
    }
    
    func sendRequest(withURL url: URL, requestMethod method: HTTPMethod, parameters: JSONDictionary? = nil, encoding: ParameterEncoding? = URLEncoding.default, completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {

        var headers: HTTPHeaders = ["content-type": "application/x-www-form-urlencoded"]
        if let _ = encoding as? JSONEncoding {
            headers = ["content-type": "application/json; charset: utf-8"]
        }
        if let token = apiToken {
            headers["authorization"] = "Bearer \(token)"
        }

        Alamofire.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .response { response in
                if let error = response.error {
                    failure(response.response, error)
                }
            }.responseJSON { response in
                if let error = response.result.error {
                    failure(response.response, error)
                } else if let responseJSON = response.result.value as? JSONDictionary, let error = responseJSON["error"] as? JSONDictionary, let description = error["description"] as? String, let code = error["code"] as? String {
                    failure(response.response, APIError(message: description, code: code))
                } else {
                    completion(response.result.value)
                }
        }
    }

    func login(completion: @escaping (Bool) -> Void, failure: @escaping FailureBlock) {
        let url = requestUrl(for: AuthUrl)
        let params = [
            "grant_type": "client_credentials",
            "client_id": APIClient.clientId,
            "client_secret": APIClient.clientSecret
            ]

        sendRequest(withURL: url, requestMethod: HTTPMethod.post, parameters: params, encoding: URLEncoding.default, completion: { json in
            if let responseJSON = json as? JSONDictionary, let accessToken = responseJSON["access_token"] as? String {
                self.apiToken = accessToken
            } else {
                failure(nil, nil)
            }
        }) { (response, error) in
            print("error getting auth token: \(String(describing: error?.localizedDescription))")
            failure(response, error)
        }
    }
}
