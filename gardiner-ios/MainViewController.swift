//
//  MainViewController.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-13.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class MainViewController: UITableViewController, CLLocationManagerDelegate {
    
    var homeList: [Contact] = []
    var locationManager:CLLocationManager = CLLocationManager()
    var locations: [[String: String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let creds = RestApi.instance.credStorage.defaultCredentialForProtectionSpace(RestApi.instance.protectionSpace)
                
        if creds == nil {
            print("doing segue")
            
            performSegueWithIdentifier("onLoginNeeded", sender: self)
        } else {
            // Assume RestApi is logged in
            print("Logged in")
            
            RestApi.instance.onLogin {
                self.reloadHome()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:HomeListCell = tableView.dequeueReusableCellWithIdentifier("homeListCell", forIndexPath: indexPath) as! HomeListCell
        let listItem:Contact = self.homeList[indexPath.row]
        
        cell.setPerson(listItem)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Counting list")
        return self.homeList.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        self.performSegueWithIdentifier("homeListDetail", sender: self.homeList[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "homeListDetail" {
            (segue.destinationViewController as! PersonLocationViewController).contact = sender as! Contact
        }
    }
    
    func reloadHome() -> Void {
        RestApi.instance.request(.GET, endpoint: "locations/", callback: { (request, response, json) -> Void in
            self.homeList = Contact.parseList(json)
            
            self.tableView.reloadData()
            
        })
        
        RestApi.instance.request(.GET, endpoint: "user/myself", callback: { (request, response, json) -> Void in
            for place in json["places"] as! [ NSDictionary ] {
                let latitude:Double     = place["latX"] as! Double
                let longitude:Double    = place["latY"] as! Double
                let identifier:String   = place["id"] as! String
                
                let region:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(latitude, longitude), radius: 100, identifier: identifier)
                
                let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                appDel.locations.append(region)
                appDel.locationsUpdated()
            }
        })
    }
    
}
