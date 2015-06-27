//
//  AppDelegate.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-01.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
                            
    var window: UIWindow?
    var locationManager: CLLocationManager = CLLocationManager()
    
    var locations: [CLRegion] = []
    
    func locationsUpdated() {
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways || !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            return
        }
        
        for region in locations {
            locationManager.startMonitoringForRegion(region)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            println("Authorization denied for location")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("Entered region \(region.identifier)")
        
        RestApi.instance.request(.POST, endpoint: "locations/enter", parameters: ["id": region.identifier]) { (request, response, json) -> Void in
            // Probably do something
        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("Exited region \(region.identifier)")
        
        RestApi.instance.request(.POST, endpoint: "locations/leave", parameters: ["id": region.identifier]) { (request, response, json) -> Void in
            // Probably do something
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("Received location update")
        var location:CLLocation = locations.last as! CLLocation
        locationManager.stopUpdatingLocation()
        
        var parameters:[String:String] = [
            "latX": NSString(format: "%f", location.coordinate.latitude) as String,
            "latY": NSString(format: "%f", location.coordinate.longitude) as String
        ]
        
        for place in self.locations {
            if (place as! CLCircularRegion).containsCoordinate(location.coordinate) {
                parameters["at"] = place.identifier
                break
            }
        }
        
        RestApi.instance.onLogin {() -> Void in
            
            RestApi.instance.request(.POST, endpoint: "locations/new", parameters: parameters) { (request, response, json) -> Void in
                
                if json["success"] as? Int == 1 {
                    println("Location updated successfully")
                }
                
            }
            
        }
        
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.requestAlwaysAuthorization()
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        locationManager.stopUpdatingLocation()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }


}

