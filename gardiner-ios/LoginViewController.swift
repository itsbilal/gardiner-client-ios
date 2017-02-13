//
//  ViewController.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-01.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
                            
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
    
    @IBAction func onLogin(_ sender: UIButton) {
        
        /*Alamofire.request(.POST, "http://localhost:8080/user/login", parameters: ["email": textEmail.text,
            "password": textPassword.text], encoding: .URL)
            .responseJSON ({(request, response, data, error) in
                var response:NSDictionary = data as NSDictionary
                
                println(response["token"])
            })
        */
        
        var restApi: RestApi = RestApi.instance
        
        restApi.setCredentials(textEmail.text!, password: textPassword.text!, onSuccess: {() in
                self.textEmail.text = "Success!"
                self.dismiss(animated: true, completion: { () -> Void in
                })
            }, onFailure: {() in
                self.textEmail.text = "Fail"
            })
        
    }

}

