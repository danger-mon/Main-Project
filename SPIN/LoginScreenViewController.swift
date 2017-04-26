//
//  LoginScreenViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 24/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginScreenViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    @IBAction func submit(_ sender: Any) {
        if usernameField.text != "" {
            if passwordField.text != "" {
                FIRAuth.auth()?.signIn(withEmail: usernameField.text!, password: passwordField.text!, completion: { (user, error) in
                    if error != nil {
                        print(error)
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "starting")
                        self.present(nextViewController, animated: true, completion: nil)
                    }
                })
            } else {
                // TODO: No usermane
            }
        } else {
            //TODO: No password
        }
    }
}
