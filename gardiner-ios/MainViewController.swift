//
//  MainViewController.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-13.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreLocation

class MainViewController: UITableViewController, CLLocationManagerDelegate {
    
    var homeList: [Contact] = []
    var locationManager:CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var sharedDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                
        if sharedDefaults.stringForKey("email") == nil {
            println("doing segue")
            
            performSegueWithIdentifier("onLoginNeeded", sender: self)
        } else {
            // Assume RestApi is logged in
            println("Logged in")
            
            RestApi.instance.onLogin {
                self.reloadHome()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.Authorized {
            locationManager.startUpdatingLocation()
        } else {
            println("Authorization denied for location")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("Received location update")
        var location:CLLocation = locations.last as CLLocation
        locationManager.stopUpdatingLocation()
        
        var parameters:[String:String] = [
            "latX": NSString(format: "%f", location.coordinate.latitude),
            "latY": NSString(format: "%f", location.coordinate.longitude)
        ]
        
        RestApi.instance.onLogin {() -> Void in
            
            RestApi.instance.request(Alamofire.Method.POST, endpoint: "locations/new", callback: { (request, response, json) -> Void in
                
                if json["success"] as? Int == 1 {
                    println("Location updated successfully")
                }
                
                }, parameters: parameters)
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("homeListCell", forIndexPath: indexPath) as UITableViewCell
        var listItem:Contact = self.homeList[indexPath.row]
        
        cell.textLabel?.text = listItem.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("Counting list")
        return self.homeList.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        self.performSegueWithIdentifier("homeListDetail", sender: self.homeList[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "homeListDetail" {
            (segue.destinationViewController as PersonLocationViewController).contact = sender as Contact
        }
    }
    
    func reloadHome() -> Void {
        RestApi.instance.request(.GET, endpoint: "locations/", callback: { (request, response, json) -> Void in
            self.homeList = Contact.parseList(json)
            
            self.tableView.reloadData()
            
        })
    }
    
}
