//
//  RestApi.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-03.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import Foundation
import Alamofire

let BASE_URL:String = "http://bilal-oneblue:8080/"

class RestApi: NSObject {
    class var instance: RestApi {
        struct Static {
            static let instance: RestApi = RestApi()
        }
        return Static.instance
    }
    
    var token: String
    var loggedIn: Bool
    
    var email: String!
    var password: String!
    
    override init() {
        token = ""
        loggedIn = false
        
        var sharedDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        email = sharedDefaults.stringForKey("email")
        password = sharedDefaults.stringForKey("password")
        
        super.init()
    }
    
    // Wrapper for the Alamofire.request function that does our own error handling
    func request(method: Alamofire.Method, endpoint: String, callback: (NSURLRequest, NSHTTPURLResponse?, NSDictionary) -> Void, parameters: Dictionary<String, String> = [String:String]()) {
        
        Alamofire.request(method, BASE_URL + endpoint, parameters: parameters, encoding: .URL)
            .responseJSON { (URLrequest, response, data, error) -> Void in
                var json:NSDictionary = data as NSDictionary;
                
                println(json)
                
                if response?.statusCode == 200 && json.objectForKey("error") == nil {
                    callback(URLrequest, response, json)
                } else if json.objectForKey("error") != nil {
                    if (json.objectForKey("code") as Int) == 1000 && self.email != nil {
                        // Relogin
                        println("Relogin time!")
                        self.logout()
                        
                        Alamofire.request(Alamofire.Method.POST, BASE_URL+"user/login/", parameters: ["email": self.email, "password": self.password], encoding: Alamofire.ParameterEncoding.URL)
                            .responseJSON({ (URLrequest2, URLresponse2, data2, error2) -> Void in
                                var json2:NSDictionary = data2 as NSDictionary
                                self.setToken(json2["token"] as String)
                                
                                self.request(method, endpoint: endpoint, callback: callback, parameters: parameters)
                            })
                        
                        
                    } else {
                        // TODO: Error handling
                        println("Error occurred")
                        println(json["error"])
                    }
                } else {
                    // TODO: Error handling
                    println("Unknown error occurred")
                }
            }
    }
    
    func setCredentials(email:String, password: String, onSuccess: () -> Void, onFailure: () -> Void) {
        
        var sharedDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        sharedDefaults.setObject(email, forKey: "email")
        sharedDefaults.setObject(password, forKey: "password")
        sharedDefaults.synchronize()
        
        self.email = email
        self.password = password
        
        request(Alamofire.Method.POST, endpoint: "user/login/", callback: {(request, response, json) in
            if response?.statusCode != 200 || json.objectForKey("error") != nil {
                self.logout()
                println("Invalid credentials")
                
                self.email = nil
                self.password = nil
                
                onFailure()
            } else {
                var token:String = json["token"] as String
                self.setToken(token)
                
                onSuccess()
            }
            
            println(json)
        }, parameters: ["email": email, "password": password])
    }
    
    func setToken(token:String) {
        self.loggedIn = true
        self.token = token
        
        Alamofire.Manager.sharedInstance.defaultHeaders["X-WWW-Authenticate"] = self.token
    }
    
    func logout() {
        self.loggedIn = false
        self.token = ""
        
        Alamofire.Manager.sharedInstance.defaultHeaders.removeValueForKey("X-WWW-Authenticate")
    }
}