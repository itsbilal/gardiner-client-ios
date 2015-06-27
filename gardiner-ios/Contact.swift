//
//  Contact.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-14.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import Foundation

class Contact {
    var id: String = ""
    var name: String = ""
    var location: String? = ""
    var email: String? = ""
    var at:String? = ""
    
    lazy var requestId:String = ""
    
    var locations: [[String: Double]] = []
    
    class func parseList(rawdata:NSDictionary) -> [Contact] {
        var list:[Contact] = []
        
        if rawdata["users"] != nil {
            for object in (rawdata["users"] as! NSArray) {
                var contact:Contact = parseJson(object as! NSDictionary)
                
                list.append(contact)
            }
        }
        
        return list
    }
    
    class func parseJson(rawContact: NSDictionary) -> Contact {
        var contact:Contact = Contact()
        
        contact.id          = rawContact["id"] as! String
        contact.name        = rawContact["name"] as! String
        contact.location    = rawContact["location"] as? String
        contact.email       = rawContact["email"] as? String
        contact.at          = rawContact["at"] as? String
        
        if rawContact["locations"] != nil {
            var locations = rawContact["locations"] as! NSArray
            
            for rawLocation in locations{
                var location:NSDictionary = rawLocation as! NSDictionary
                if location["latX"] == nil {
                    continue
                }
                
                contact.locations.append(["latX": location["latX"] as! Double,
                    "latY": location["latY"] as! Double])
            }
        }
        
        return contact
    }
    
    func request() {
        RestApi.instance.request(.POST, endpoint: "contacts/user/\(self.id)/request")
    }
}