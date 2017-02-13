//
//  PersonLocationViewController.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-14.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import UIKit
import MapKit

class PersonLocationViewController: UIViewController {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var contact:Contact = Contact()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //idLabel.text = contact.id
        self.navigationItem.title = contact.name
        
        if contact.locations.count > 0 {
            setMapLocation(contact.locations[0]["latX"],
                longitude: contact.locations[0]["latY"])
        } else {
            mapView.isHidden = true
            print("hiding mapview")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setMapLocation(_ latitude: Double?, longitude: Double?) {
        let annotation:MKPointAnnotation = MKPointAnnotation()
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        
        annotation.coordinate = coordinate
        annotation.title = contact.name
        annotation.subtitle = "Location"
        
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: false)
        // Set region
        
        let region:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        mapView.region = region
    }

}
