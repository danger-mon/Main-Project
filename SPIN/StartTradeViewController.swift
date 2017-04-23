//
//  StartTradeViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 06/02/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import Firebase

class StartTradeViewController: UIViewController {
    
    var dressReference: String = ""
    var ownerReference: String = ""
    var ownerName: String = ""
    var dressTitle: String = ""
    
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
        
        databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("outgoingRequests").child(dressReference).setValue(post)
        
        databaseRef.child("Users").child(ownerReference).child("incomingRequests").child(dressReference).setValue(post)
        
        _ = self.navigationController?.popViewController(animated: true)

    }
    
}
