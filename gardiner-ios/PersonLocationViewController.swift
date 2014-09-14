//
//  PersonLocationViewController.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-09-14.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import UIKit

class PersonLocationViewController: UIViewController {
    
    @IBOutlet weak var idLabel: UILabel!
    var contact:Contact = Contact()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        idLabel.text = contact.id
        self.navigationItem.title = contact.name
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

}
