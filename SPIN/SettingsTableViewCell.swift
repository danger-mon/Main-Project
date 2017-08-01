//
//  SettingsTableViewCell.swift
//  SPIN
//
//  Created by Pelayo Martinez on 25/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    var ref = ""
    var parentTableViewController: BlockedUsersTableViewController = BlockedUsersTableViewController()
    weak var finishDelegate: TapDelegateBlocked?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func unblock(_ sender: Any) {
    
        //let reference = FIRDatabase.database().reference().child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("conversations").child(ref).child("blocked")
        
        // Get rid of blocked = true on the conversations so that they show up again after unblocking.
        let fanoutObject = ["/Users/\((FIRAuth.auth()?.currentUser?.uid)!)/conversations/\(ref)/blocked": NSNull()]
        
            //reference.setValue(NSNull())
        
        FIRDatabase.database().reference().updateChildValues(fanoutObject) { (error, ref) in
            if error != nil {
                print("error")
            } else {
                // If succesful, refresh list of unblocked
                self.finishDelegate?.didFinishUnblocking()
                self.parentTableViewController.blockedUsers = []
                self.parentTableViewController.downloadBlockedUsers()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol TapDelegateBlocked: class {
    func didFinishUnblocking()
}
