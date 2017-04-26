//
//  SettingsTableViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 25/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import OneSignal
import FacebookLogin

class SettingsTableViewController: UITableViewController {
    
    var settings = ("Log Out", "logout")
    var changePassword = "changePassword"

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsTableViewCell
        if indexPath.row == 0 {
            cell.name.text = settings.0
        } else if indexPath.row == 1 {
            cell.name.text = "Change Password"
        } else if indexPath.row == 2 {
            cell.name.text = "Blocked Users"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            logout()
        } else if indexPath.row == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "changePassword")
            self.navigationController?.pushViewController(nextViewController, animated: true)
        } else if indexPath.row == 2 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "blockedUsers")
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func logout() {
        var fanoutObject: [String: Any] = [:]
        fanoutObject["/Users/\((FIRAuth.auth()?.currentUser?.uid)!)/userData/oneSignalKey"] = NSNull()
        fanoutObject["/OneSignalIDs/\((FIRAuth.auth()?.currentUser?.uid)!)"] = NSNull()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "login")
        self.present(nextViewController, animated: true, completion: nil)
        
        
        
        let firebaseAuth = FIRAuth.auth()
        do {
            FIRDatabase.database().reference().updateChildValues(fanoutObject)
            
            try firebaseAuth?.signOut()
            let loginManager = LoginManager()
            loginManager.logOut()
            OneSignal.deleteTag("userID")
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }

}
