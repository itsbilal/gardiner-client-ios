//
//  NewPlaceViewController.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-12-12.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NewPlaceViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    
    var currentSelectedCoordinate:CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var lpgr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "onLongPress:")
        mapView.addGestureRecognizer(lpgr)
    }
    
    func onLongPress(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Began {
            return
        }
        
        var touchPoint:CGPoint = gestureRecognizer.locationInView(mapView)
        var locationCoordinate:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        var annotation:MKPointAnnotation = MKPointAnnotation()
        annotation.title = "Location to add"
        annotation.coordinate = locationCoordinate
        
        self.mapView.addAnnotation(annotation)
        
        currentSelectedCoordinate = locationCoordinate
        self.nextBarButton.enabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButtonClick(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        (segue.destinationViewController as! NewPlace2ViewController).location = self.currentSelectedCoordinate
    }
    

}
