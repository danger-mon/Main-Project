//
//  LoginScreenViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 24/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginScreenViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapcontroller = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapcontroller)
        usernameField.delegate = self
        usernameField.returnKeyType = .done
        passwordField.delegate = self
        passwordField.returnKeyType = .done
    }
    
    func didTapBackground() {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func resetPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Missing Field", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))

        if usernameField.text != "" {
            FIRAuth.auth()?.sendPasswordReset(withEmail: self.usernameField.text!, completion: { (error) in
                if error != nil {
                    alert.message = error?.localizedDescription
                    self.present(alert, animated: true, completion: nil)
                } else {
                    alert.message = "Password Reset Link Sent"
                    alert.title = "Success!"
                    self.present(alert, animated: true, completion: nil)
                    
                }
            })
        } else {
            alert.message = "Please enter your email."
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        
        usernameField.textColor = UIColor.lightGray
        passwordField.textColor = UIColor.lightGray
        usernameField.isEnabled = false
        passwordField.isEnabled = false
        
        let alert = UIAlertController(title: "Missing Field", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
        
        if usernameField.text != "" {
            
            if passwordField.text != "" {
                
                FIRAuth.auth()?.signIn(withEmail: usernameField.text!, password: passwordField.text!, completion: { (user, error) in
                    if error != nil {
                        alert.message = "Error authenticating. Check your details or try again later."
                        self.present(alert, animated: true, completion: nil)
                        self.usernameField.textColor = UIColor.black
                        self.passwordField.textColor = UIColor.black
                        self.usernameField.isEnabled = true
                        self.passwordField.isEnabled = true
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "starting")
                        self.present(nextViewController, animated: true, completion: nil)
                    }
                })
                
            } else {
                alert.message = "Please enter a password."
                self.present(alert, animated: true, completion: nil)
                self.usernameField.textColor = UIColor.black
                self.passwordField.textColor = UIColor.black
                self.usernameField.isEnabled = true
                self.passwordField.isEnabled = true
            }
        } else {
            alert.message = "Please enter an email."
            self.present(alert, animated: true, completion: nil)
            self.usernameField.textColor = UIColor.black
            self.passwordField.textColor = UIColor.black
            self.usernameField.isEnabled = true
            self.passwordField.isEnabled = true
        }
    }
}
