//
//  LoginViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 12/12/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth
import FirebaseDatabase
import OneSignal

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        if String(describing: result) == "cancelled" {
            print("cancelled")
        } else {
            
            loginButton.isHidden = true
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
        
            FIRAuth.auth()?.signIn(with: credential, completion: {
                (user,error) in
                
                let databaseRef = FIRDatabase.database().reference()
            
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                let userID = (status.subscriptionStatus.userId)!
            
                databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userData").observeSingleEvent(of: .value, with: { snapshot in
                
                    if snapshot.value is NSNull {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "details")
                        self.present(nextViewController, animated: true, completion: nil)
                    } else {
                        
                        var fanoutObject: [String: AnyObject] = [:]
                        fanoutObject["/Users/\((FIRAuth.auth()?.currentUser?.uid)!)/userData/oneSignalKey"] = userID as AnyObject
                        fanoutObject["/OneSignalIDs/\((FIRAuth.auth()?.currentUser?.uid)!)"] = userID as AnyObject
                        databaseRef.updateChildValues(fanoutObject)
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "starting")
                        self.present(nextViewController, animated: true, completion: nil)
                    }
                })
                return
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("logged out")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
        loginButton.center = view.center
        loginButton.delegate = self
        
        view.addSubview(loginButton)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AccessToken.current != nil {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "starting")
            self.present(nextViewController, animated: true, completion: nil)
        }
    }
}
