//
//  MainViewController.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-13.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
