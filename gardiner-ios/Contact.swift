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
    
    class func parseList(rawdata:NSDictionary) -> [Contact] {
        var list:[Contact] = []
        
        if rawdata["users"] != nil {
            for object in (rawdata["users"] as NSArray) {
                var contact:Contact = Contact()
                var rawContact:NSDictionary = object as NSDictionary
                
                contact.id          = rawContact["id"] as String
                contact.name        = rawContact["name"] as String
                contact.location    = rawContact["location"] as? String
            }
        }
        
        return list
    }
}