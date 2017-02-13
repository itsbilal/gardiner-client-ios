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
        
        let lpgr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(NewPlaceViewController.onLongPress(_:)))
        mapView.addGestureRecognizer(lpgr)
    }
    
    func onLongPress(_ gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.began {
            return
        }
        
        let touchPoint:CGPoint = gestureRecognizer.location(in: mapView)
        let locationCoordinate:CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation:MKPointAnnotation = MKPointAnnotation()
        annotation.title = "Location to add"
        annotation.coordinate = locationCoordinate
        
        self.mapView.addAnnotation(annotation)
        
        currentSelectedCoordinate = locationCoordinate
        self.nextBarButton.isEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButtonClick(_ sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        (segue.destination as! NewPlace2ViewController).location = self.currentSelectedCoordinate
    }
    

}
