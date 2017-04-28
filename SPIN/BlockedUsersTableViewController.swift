//
//  BlockedUsersTableViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 26/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class BlockedUsersTableViewController: UITableViewController, TapDelegateBlocked {

    override func viewDidLoad() {
        super.viewDidLoad()
        downloadBlockedUsers()
    }
    
    var blockedUsers: [(String, String)] = []
    
    func didFinishUnblocking() {
        print("unblocking")
        blockedUsers = []
        downloadBlockedUsers()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return blockedUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedUser") as! SettingsTableViewCell
        cell.name.text = blockedUsers[indexPath.row].0
        cell.ref = blockedUsers[indexPath.row].1
        cell.parentTableViewController = self
        cell.finishDelegate = self
        return cell
    }
    
    func downloadBlockedUsers() {
        let query = FIRDatabase.database().reference().child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("conversations").queryOrdered(byChild: "blocked").queryEqual(toValue: "true")
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            var dict: [String: [String: Any]] = [:]
            if snapshot.value is NSNull { } else {
                dict = snapshot.value as! [String : [String : Any]]
                for dictionaryChild in dict {
                    self.blockedUsers.append((dictionaryChild.value["name"] as! String, dictionaryChild.key))
                    self.tableView.reloadData()
                    
                }
            }
        })
    }
}
