//
//  RestApi.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-03.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import Foundation
import Alamofire

let BASE_URL:String = "http://localhost:8080/"

class RestApi {
    class var instance: RestApi {
        struct Static {
            static let instance: RestApi = RestApi()
        }
        return Static.instance
    }
    
    // Wrapper for the Alamofire.request function that does our own error handling
    func request(method: Alamofire.Method, endpoint: String, parameters: Dictionary<String, String>, callback: (NSURLRequest, NSHTTPURLResponse?, AnyObject?) -> Void) {
        Alamofire.request(method, BASE_URL + endpoint, parameters: parameters, encoding: .URL)
            .responseJSON { (URLrequest, response, data, error) -> Void in
                if response?.statusCode != 200 {
                    callback(URLrequest, response, data)
                } else {
                    // TODO: Error handling
                }
            }
    }
    
    func login(email: String, password: String) {
        
    }
}