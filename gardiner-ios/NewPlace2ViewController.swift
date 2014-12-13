//
//  NewPlace2ViewController.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-12-13.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import UIKit
import CoreLocation

class NewPlace2ViewController: UITableViewController {
    
    var location:CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPlaceSubmit(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
