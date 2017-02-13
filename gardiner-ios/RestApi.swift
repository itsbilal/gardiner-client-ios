//
//  RestApi.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-03.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import Foundation

let BASE_URL:String = "http://159.203.73.79:8080/"

enum Method : CustomStringConvertible {
    case get
    case post
    case put
    case delete
    
    var description:String {
        switch self {
        case .get: return "GET";
        case .post: return "POST";
        case .put: return "PUT";
        case .delete: return "DELETE";
        }
    }
}

enum ParameterEncoding {
    case url
    case json
    
    var mimeType:String {
        switch self {
        case .url: return "application/x-www-form-urlencoded";
        case .json: return "application/json";
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
    
    
    let protectionSpace:URLProtectionSpace = URLProtectionSpace(
        host: "159.203.73.79",
        port: 8080,
        protocol: "http",
        realm: nil,
        authenticationMethod: NSURLAuthenticationMethodHTMLForm
    )
    var credStorage:URLCredentialStorage = URLCredentialStorage.shared
    
    var onLoginCallbacks: [() -> Void] = []
    
    override init() {
        token = ""
        loggedIn = false
        super.init()
        
        let creds:URLCredential? = credStorage.defaultCredential(for: protectionSpace)

        if creds != nil {
            email = creds?.user
            password = creds?.password
        } else {
            return
        }
        
        
        request(Method.post, endpoint: "user/login/", parameters: ["email": email as AnyObject, "password": password as AnyObject]) {(request, response, json) in
                if response?.statusCode != 200 || json.object(forKey: "error") != nil {
                    self.logout()
                    print("Invalid credentials")
                    
                    self.email = nil
                    self.password = nil
                    
                } else {
                    let token:String = json["token"] as! String
                    self.setSessionToken(token)
                }
            
                print(json)
            }
    }
    
    func onLogin(_ callback: @escaping () -> Void) {
        if self.token.isEmpty {
            onLoginCallbacks.append(callback)
        } else {
            callback()
        }
    }
    
    // Wrapper for the Alamofire.request function that does our own error handling
    func request(_ method: Method, endpoint: String, parameters: [String:AnyObject] = [:], callback: ((URLRequest, HTTPURLResponse?, NSDictionary) -> Void)? = nil ) {
        
        var encoding:ParameterEncoding = .url
        if method == .post {
            encoding = .json
        }
        
        let url:URL = URL(string: BASE_URL + endpoint)!
        var urlRequest:NSMutableURLRequest = NSMutableURLRequest(url: url)
        urlRequest.httpMethod = method.description
        urlRequest.setValue(encoding.mimeType, forHTTPHeaderField: "Content-Type")
    
        if loggedIn && !token.isEmpty {
            urlRequest.setValue(token, forHTTPHeaderField: "X-WWW-Authenticate")
        }
        
        var requestBody:Data?
        if parameters.count > 0 {
            if encoding == .json {
                var error:NSError?
                do {
                    requestBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                } catch var error1 as NSError {
                    error = error1
                    requestBody = nil
                }
                if (error != nil) {
                    return
                }
            } else {
                var requestString:String = ""
                for (key, value) in parameters as! [String:String] {
                    requestString += "\(key)=\(value)&"
                }
                requestString = requestString.substring(to: requestString.characters.index(requestString.endIndex, offsetBy: -1))
                requestBody = requestString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            }
            urlRequest.httpBody = requestBody!
        }
        
        let session:URLSession = URLSession.shared
        let sessionTask:URLSessionDataTask = session.dataTask(with: urlRequest, completionHandler: { (rawdata, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            
            var jsonReadError: NSError?
            let json:NSDictionary = (try! JSONSerialization.jsonObject(with: rawdata!, options: [])) as! NSDictionary
            
            print(json)

            if jsonReadError != nil {
                print(error)
                return
            }
            
            if json["error"] != nil {
                print(json["error"])
                return
            }
            
            
            if (response as! HTTPURLResponse).statusCode == 200 && json.object(forKey: "error") == nil {
                callback?(urlRequest, response as? HTTPURLResponse, json)
            } else if json.object(forKey: "error") != nil {
                if (json.object(forKey: "code") as? Int) == 1000 && self.email != nil {
                    // Relogin
                    print("Relogin time!")
                    self.logout()
                    
                    self.request(.post, endpoint: "user/login/", parameters: ["email": self.email, "password": self.password]) { (URLrequest2, URLresponse2, data2) -> Void in
                            var json2:NSDictionary = data2
                            self.setSessionToken(json2["token"] as! String)
                            
                            self.request(method, endpoint: endpoint, parameters: parameters, callback: callback)
                        }
                    
                    
                } else {
                    // TODO: Error handling
                    print("Error occurred")
                    print(json["error"])
                }
            } else {
                // TODO: Error handling
                print("Unknown error occurred")
            }
        })
        sessionTask.resume()
    }
    
    func setCredentials(_ email:String, password: String, onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        
        let creds = URLCredential(user: email, password: password, persistence: URLCredential.Persistence.permanent)
        self.credStorage.setDefaultCredential(creds, for: protectionSpace)
        
        self.email = email
        self.password = password
        
        request(.post, endpoint: "user/login/", parameters: ["email": email as AnyObject, "password": password as AnyObject]) {(request, response, json) in
            if response?.statusCode != 200 || json.object(forKey: "error") != nil {
                self.logout()
                print("Invalid credentials")
                
                self.email = nil
                self.password = nil
                
                onFailure()
            } else {
                let token:String = json["token"] as! String
                self.setSessionToken(token)
                
                onSuccess()
            }
            
            print(json)
        }
    }
    
    func setSessionToken(_ token:String) {
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
