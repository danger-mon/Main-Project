//
//  StartTradeViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 06/02/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

class StartTradeViewController: UIViewController {
    
    var dressReference: String = ""
    var ownerReference: String = ""
    var ownerName: String = ""
    var dressTitle: String = ""
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem?.setBadge(text: "\(BadgeHandler.messageBadgeNumber)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func beginTrade(_ sender: Any) {
        print("requesting")
        
        self.yesButton.isEnabled = false
        self.cancelButton.isEnabled = false
        
        let databaseRef = FIRDatabase.database().reference()
        
        let post = [ "dressReference" : dressReference,
                     "dressTitle": dressTitle,
                     "requestUid" : (FIRAuth.auth()?.currentUser?.uid)!,
                     "ownerUid" : ownerReference,
                     "ownerName": ownerName,
                     "requesterName": ProfileViewController.ownUsername,
                     "timestamp" : NSDate.timeIntervalSinceReferenceDate,
                     "rentBuy" : "rent",
                     "price" : "£15"] as [String : Any]
        
        
        databaseRef.child("OneSignalIDs").child(ownerReference).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value is NSNull { } else {
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                let pushToken = status.subscriptionStatus.pushToken
                _ = status.subscriptionStatus.userId

                if pushToken != nil {
                    let notificationContent = [
                        "include_player_ids": snapshot.value as! String,
                        "contents": ["en": "\(Profile.ownUsername) sent you a request"],
                        "data": ["type": "request"],
                        "ios_badgeType": "Increase",
                        "ios_badgeCount": 1
                        ] as [String : Any]
                    print(notificationContent)
                    OneSignal.postNotification(notificationContent)
                }
            }
            
            var fanoutObject: [String: [String: Any]] = [:]
            
            databaseRef.child("RequestData").child(self.dressReference).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let requestID = databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("outgoingRequests").childByAutoId().key
                
                fanoutObject["/Users/\((FIRAuth.auth()?.currentUser?.uid)!)/outgoingRequests/\(requestID)"] = post
                fanoutObject["/Users/\(self.ownerReference)/incomingRequests/\(requestID)"] = post

                
                if snapshot.value is NSNull {
                    var dict = [(FIRAuth.auth()?.currentUser?.uid)!: "true"]
                    fanoutObject["/RequestData/\(self.dressReference)"] = dict
                    databaseRef.updateChildValues(fanoutObject)
                    _ = self.navigationController?.popViewController(animated: true)
                    
                } else {
                    var dict: [String: String] = snapshot.value as! [String : String]
                    dict[(FIRAuth.auth()?.currentUser?.uid)!] = "true"
                    fanoutObject["/RequestData/\(self.dressReference)"] = dict
                    
                    databaseRef.updateChildValues(fanoutObject)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
            
            
        })
    }
    
}
