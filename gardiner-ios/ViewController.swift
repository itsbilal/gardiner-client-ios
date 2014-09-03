//
//  ViewController.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-01.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
                            
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(sender: UIButton) {
        
        Alamofire.request(.POST, "http://localhost:8080/user/login", parameters: ["email": textEmail.text,
            "password": textPassword.text], encoding: .URL)
            .responseJSON ({(request, response, data, error) in
                
            })
        
    }

}

