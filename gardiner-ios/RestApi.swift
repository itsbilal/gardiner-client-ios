//
//  RestApi.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-03.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import Foundation

let BASE_URL:String = "http://104.131.171.82:8080/"

enum Method : Printable {
    case GET
    case POST
    case PUT
    case DELETE
    
    var description:String {
        switch self {
        case .GET: return "GET";
        case .POST: return "POST";
        case .PUT: return "PUT";
        case .DELETE: return "DELETE";
        }
    }
}

enum ParameterEncoding {
    case URL
    case JSON
    
    var mimeType:String {
        switch self {
        case .URL: return "application/x-www-form-urlencoded";
        case .JSON: return "application/json";
        }
    }
}

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
        
        
        request(Method.POST, endpoint: "user/login/", parameters: ["email": email, "password": password]) {(request, response, json) in
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
            }
    }
    
    func onLogin(callback: () -> Void) {
        if self.token.isEmpty {
            onLoginCallbacks.append(callback)
        } else {
            callback()
        }
    }
    
    // Wrapper for the Alamofire.request function that does our own error handling
    func request(method: Method, endpoint: String, parameters: [String:AnyObject] = [:], callback: ((NSURLRequest, NSHTTPURLResponse?, NSDictionary) -> Void)? = nil ) {
        
        var encoding:ParameterEncoding = .URL
        if method == .POST {
            encoding = .JSON
        }
        
        let url:NSURL = NSURL(string: BASE_URL + endpoint)!
        var urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = method.description
        urlRequest.setValue(encoding.mimeType, forHTTPHeaderField: "Content-Type")
    
        if loggedIn && !token.isEmpty {
            urlRequest.setValue(token, forHTTPHeaderField: "X-WWW-Authenticate")
        }
        
        var requestBody:NSData?
        if parameters.count > 0 {
            if encoding == .JSON {
                var error:NSError?
                requestBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &error)
                if (error != nil) {
                    return
                }
            } else {
                var requestString:String = ""
                for (key, value) in parameters as! [String:String] {
                    requestString += "\(key)=\(value)&"
                }
                requestString = requestString.substringToIndex(advance(requestString.endIndex, -1))
                requestBody = requestString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            }
            urlRequest.HTTPBody = requestBody!
        }
        
        let session:NSURLSession = NSURLSession.sharedSession()
        let sessionTask:NSURLSessionDataTask = session.dataTaskWithRequest(urlRequest, completionHandler: { (rawdata, response, error) -> Void in
            
            if error != nil {
                println(error)
                return
            }
            
            var jsonReadError: NSError?
            var json:NSDictionary = NSJSONSerialization.JSONObjectWithData(rawdata, options: nil, error: &jsonReadError) as! NSDictionary
            
            println(json)

            if jsonReadError != nil {
                println(error)
                return
            }
            
            if json["error"] != nil {
                println(json["error"])
                return
            }
            
            
            if (response as! NSHTTPURLResponse).statusCode == 200 && json.objectForKey("error") == nil {
                callback?(urlRequest, response as? NSHTTPURLResponse, json)
            } else if json.objectForKey("error") != nil {
                if (json.objectForKey("code") as? Int) == 1000 && self.email != nil {
                    // Relogin
                    println("Relogin time!")
                    self.logout()
                    
                    self.request(.POST, endpoint: "user/login/", parameters: ["email": self.email, "password": self.password]) { (URLrequest2, URLresponse2, data2) -> Void in
                            var json2:NSDictionary = data2
                            self.setSessionToken(json2["token"] as! String)
                            
                            self.request(method, endpoint: endpoint, parameters: parameters, callback: callback)
                        }
                    
                    
                } else {
                    // TODO: Error handling
                    println("Error occurred")
                    println(json["error"])
                }
            } else {
                // TODO: Error handling
                println("Unknown error occurred")
            }
        })
        sessionTask.resume()
    }
    
    func setCredentials(email:String, password: String, onSuccess: () -> Void, onFailure: () -> Void) {
        
        var creds = NSURLCredential(user: email, password: password, persistence: NSURLCredentialPersistence.Permanent)
        self.credStorage.setDefaultCredential(creds, forProtectionSpace: protectionSpace)
        
        self.email = email
        self.password = password
        
        request(.POST, endpoint: "user/login/", parameters: ["email": email, "password": password]) {(request, response, json) in
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
        }
    }
    
    func setSessionToken(token:String) {
        self.loggedIn = true
        self.token = token
        
        for callback in onLoginCallbacks {
            callback()
        }
        
        onLoginCallbacks.removeAll()
    }
    
    func logout() {
        self.loggedIn = false
        self.token = ""
    }
}