//
//  ContactsViewController.swift
//  gardiner-ios
//
//  Created by Bilal Akhtar on 2014-10-19.
//  Copyright (c) 2014 Bilal Akhtar. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var contacts:[Contact] = []
    
    @IBOutlet weak var tableView: UITableView!
    class ContactsSearchDelegate: NSObject, UITableViewDataSource, UISearchDisplayDelegate, UITableViewDelegate {
        var searchContacts:[Contact] = []
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("contactsSearchCell") as UITableViewCell
            var contact = searchContacts[indexPath.row]
            cell.textLabel?.text = contact.name
            
            return cell
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return searchContacts.count
        }
        
        func searchDisplayController(controller: UISearchDisplayController, didLoadSearchResultsTableView tableView: UITableView) {
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "contactsSearchCell")
        }
        
        func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
            RestApi.instance.request(.GET, endpoint: "contacts/search", callback: { (request, response, json) -> Void in
                self.searchContacts = Contact.parseList(json)
                controller.searchResultsTableView.reloadData()
                
            }, parameters: ["name":searchString])
            
            return false
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            println("Selected \(searchContacts[indexPath.row].name) in search results")
            
            let contact:Contact = searchContacts[indexPath.row]
            
            RestApi.instance.request(.POST, endpoint: "contacts/user/\(contact.id)/request", callback: { (request, response, json) -> Void in
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            })
        }
    }
    
    var contactSearchDelegate:ContactsSearchDelegate = ContactsSearchDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchDisplayController?.delegate = contactSearchDelegate
        self.searchDisplayController?.searchResultsDataSource = contactSearchDelegate
        self.searchDisplayController?.searchResultsDelegate = contactSearchDelegate

        // Do any additional setup after loading the view.
        
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("requestsListCell") as UITableViewCell
        var contact:Contact = self.contacts[indexPath.row]
        
        cell.textLabel?.text = contact.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let contact:Contact = self.contacts[indexPath.row]
        self.contacts.removeAtIndex(indexPath.row)
        tableView.reloadData()
        
        RestApi.instance.request(.POST, endpoint: "contacts/requests/\(contact.requestId)/respond", callback: { (request, response, json) -> Void in
            
        }, parameters: ["response":"1"])
    }
    
    func refresh() {
        RestApi.instance.request(.GET, endpoint: "contacts/requests", callback: { (request, response, json) -> Void in
            for request in json["requests"] as NSArray {
                var contact:Contact = Contact.parseJson(request["from"] as NSDictionary)
                contact.requestId = request["id"] as String
                
                self.contacts.append(contact)
            }
            
            self.tableView.reloadData()
        })
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
