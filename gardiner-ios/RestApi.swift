//
//  RestApi.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-03.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import Foundation
import Alamofire

let BASE_URL:String = "http://104.131.171.82:8080/"

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
    
    
    let protectionSpace:NSURLProtectionSpace = NSURLProtectionSpace(
        host: "104.131.171.82",
        port: 8080,
        `protocol`: "http",
        realm: nil,
        authenticationMethod: NSURLAuthenticationMethodHTMLForm
    )
    var credStorage:NSURLCredentialStorage = NSURLCredentialStorage.sharedCredentialStorage()
    
    var onLoginCallbacks: [() -> Void] = []
    
    override init() {
        token = ""
        loggedIn = false
        super.init()
        
        var creds:NSURLCredential? = credStorage.defaultCredentialForProtectionSpace(protectionSpace)

        if creds != nil {
            email = creds?.user
            password = creds?.password
        } else {
            return
        }
        
        
        request(Alamofire.Method.POST, endpoint: "user/login/", callback: {(request, response, json) in
                if response?.statusCode != 200 || json.objectForKey("error") != nil {
                    self.logout()
                    println("Invalid credentials")
                    
                    self.email = nil
                    self.password = nil
                    
                } else {
                    var token:String = json["token"] as! String
                    self.setSessionToken(token)
                }
            
                println(json)
            }, parameters: ["email": email, "password": password])
    }
    
    func onLogin(callback: () -> Void) {
        if self.token.isEmpty {
            onLoginCallbacks.append(callback)
        } else {
            callback()
        }
    }
    
    // Wrapper for the Alamofire.request function that does our own error handling
    func request(method: Alamofire.Method, endpoint: String, callback: (NSURLRequest, NSHTTPURLResponse?, NSDictionary) -> Void, parameters: Dictionary<String, String> = [String:String]()) {
        
        Alamofire.request(method, BASE_URL + endpoint, parameters: parameters, encoding: .URL)
            .responseJSON { (URLrequest, response, data, error) -> Void in
                if error != nil {
                    return
                }
                
                var json:NSDictionary = data as! NSDictionary
                
                if json["error"] != nil {
                    return
                }
                
                println(json)
                
                if response?.statusCode == 200 && json.objectForKey("error") == nil {
                    callback(URLrequest, response, json)
                } else if json.objectForKey("error") != nil {
                    if (json.objectForKey("code") as? Int) == 1000 && self.email != nil {
                        // Relogin
                        println("Relogin time!")
                        self.logout()
                        
                        Alamofire.request(Alamofire.Method.POST, BASE_URL+"user/login/", parameters: ["email": self.email, "password": self.password], encoding: Alamofire.ParameterEncoding.URL)
                            .responseJSON(completionHandler: { (URLrequest2, URLresponse2, data2, error2) -> Void in
                                var json2:NSDictionary = data2 as! NSDictionary
                                self.setSessionToken(json2["token"] as! String)
                                
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
        
        var creds = NSURLCredential(user: email, password: password, persistence: NSURLCredentialPersistence.Permanent)
        self.credStorage.setDefaultCredential(creds, forProtectionSpace: protectionSpace)
        
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
                var token:String = json["token"] as! String
                self.setSessionToken(token)
                
                onSuccess()
            }
            
            println(json)
        }, parameters: ["email": email, "password": password])
    }
    
    func setSessionToken(token:String) {
        self.loggedIn = true
        self.token = token
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders?["X-WWW-Authenticate"] = self.token
        
        for callback in onLoginCallbacks {
            callback()
        }
        
        onLoginCallbacks.removeAll()
    }
    
    func logout() {
        self.loggedIn = false
        self.token = ""
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders?.removeValueForKey("X-WWW-Authenticate")
    }
}