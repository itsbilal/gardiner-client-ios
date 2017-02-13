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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let creds = RestApi.instance.credStorage.defaultCredential(for: RestApi.instance.protectionSpace)
                
        if creds == nil {
            print("doing segue")
            
            performSegue(withIdentifier: "onLoginNeeded", sender: self)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HomeListCell = tableView.dequeueReusableCell(withIdentifier: "homeListCell", for: indexPath) as! HomeListCell
        let listItem:Contact = self.homeList[indexPath.row]
        
        cell.setPerson(listItem)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Counting list")
        return self.homeList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.performSegue(withIdentifier: "homeListDetail", sender: self.homeList[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeListDetail" {
            (segue.destination as! PersonLocationViewController).contact = sender as! Contact
        }
    }
    
    func reloadHome() -> Void {
        RestApi.instance.request(.get, endpoint: "locations/", callback: { (request, response, json) -> Void in
            self.homeList = Contact.parseList(json)
            
            self.tableView.reloadData()
            
        })
        
        RestApi.instance.request(.get, endpoint: "user/myself", callback: { (request, response, json) -> Void in
            for place in json["places"] as! [ NSDictionary ] {
                let latitude:Double     = place["latX"] as! Double
                let longitude:Double    = place["latY"] as! Double
                let identifier:String   = place["id"] as! String
                
                let region:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(latitude, longitude), radius: 100, identifier: identifier)
                
                let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDel.locations.append(region)
                appDel.locationsUpdated()
            }
        })
    }
    
}
