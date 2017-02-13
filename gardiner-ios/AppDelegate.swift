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
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways || !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion) {
            return
        }
        
        for region in locations {
            locationManager.startMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Authorization denied for location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region \(region.identifier)")
        
        RestApi.instance.request(.post, endpoint: "locations/enter", parameters: ["id": region.identifier]) { (request, response, json) -> Void in
            // Probably do something
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region \(region.identifier)")
        
        RestApi.instance.request(.post, endpoint: "locations/leave", parameters: ["id": region.identifier]) { (request, response, json) -> Void in
            // Probably do something
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Received location update")
        let location:CLLocation = locations.last!
        locationManager.stopUpdatingLocation()
        
        var parameters:[String:String] = [
            "latX": NSString(format: "%f", location.coordinate.latitude) as String,
            "latY": NSString(format: "%f", location.coordinate.longitude) as String
        ]
        
        for place in self.locations {
            if (place as! CLCircularRegion).contains(location.coordinate) {
                parameters["at"] = place.identifier
                break
            }
        }
        
        RestApi.instance.onLogin {() -> Void in
            
            RestApi.instance.request(.post, endpoint: "locations/new", parameters: parameters) { (request, response, json) -> Void in
                
                if json["success"] as? Int == 1 {
                    print("Location updated successfully")
                }
                
            }
            
        }
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.requestAlwaysAuthorization()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        locationManager.stopUpdatingLocation()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }


}

