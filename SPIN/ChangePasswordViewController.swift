//
//  ChangePasswordViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 25/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseAuth

// Screen where the user can change their password.

class ChangePasswordViewController: UIViewController {
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword1: UITextField!
    @IBOutlet weak var newPassword2: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var email: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.layer.cornerRadius = 7
        submitButton.layer.borderColor = UIColor.darkGray.cgColor
        submitButton.layer.borderWidth = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //TODO: Add alerts
    @IBAction func submit(_ sender: Any) {
        if newPassword1.text == newPassword2.text {
            
            // Get Credential from Firebase to prove the user himself is asking to change password.
            let credential = FIREmailPasswordAuthProvider.credential(withEmail: email.text!, password: oldPassword.text!)
            
            // Get the current user object from Firebase
            let user = FIRAuth.auth()?.currentUser
            
            // Authenticate the credential obtained above to make sure password is correct
            user?.reauthenticate(with: credential, completion: { (error) in
                if error != nil{
                    // If password is incorrect or there is an error authenticating
                    // TODO: Add an actual alert.
                    print("Authenticating  error")
                }else{
                    // Call Firebase's update password function with the text from the new password field as the new password
                    FIRAuth.auth()?.currentUser?.updatePassword(self.newPassword2.text!, completion: { (error) in
                        if error != nil {
                            // If error updating
                            //TODO: Add an actual alert
                            print(error?.localizedDescription)
                        } else {
                            // If succesfully changed
                            // TODO: Add an actual alert
                            print("Success!")
                            // Return to previuos screen
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            })

        }
    }

}
