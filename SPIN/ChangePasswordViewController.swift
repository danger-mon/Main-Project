//
//  ChangePasswordViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 25/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseAuth

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
            let credential = FIREmailPasswordAuthProvider.credential(withEmail: email.text!, password: oldPassword.text!)
            
            let user = FIRAuth.auth()?.currentUser
            
            user?.reauthenticate(with: credential, completion: { (error) in
                if error != nil{
                    print("Authenticating  error")
                }else{
                    FIRAuth.auth()?.currentUser?.updatePassword(self.newPassword2.text!, completion: { (error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        } else {
                            print("Success!")
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            })

        }
    }

}
