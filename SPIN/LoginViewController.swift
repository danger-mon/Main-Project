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
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailLoginButton: UIButton!
    
    @IBAction func register(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "register")
        self.navigationController?.pushViewController(nextViewController, animated: true)
        //self.present(nextViewController, animated: true, completion: nil)
    }
    let myLoginButton = UIButton(type: .custom)
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        /*
        if String(describing: result) == "cancelled" {
            print("cancelled")
        } else {
            
            loginButton.isHidden = true
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
        
            FIRAuth.auth()?.signIn(with: credential, completion: {
                (user,error) in
                
                let databaseRef = FIRDatabase.database().reference()
            
                OneSignal.sendTag("userID", value: (FIRAuth.auth()?.currentUser?.uid)!)
                
                
                OneSignal.promptLocation()
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                let userID = (status.subscriptionStatus.userId)!
                
                var fanoutObject: [String: AnyObject] = [:]
                fanoutObject["/Users/\((FIRAuth.auth()?.currentUser?.uid)!)/userData/oneSignalKey"] = userID as AnyObject
                fanoutObject["/OneSignalIDs/\((FIRAuth.auth()?.currentUser?.uid)!)"] = userID as AnyObject
                OneSignal.sendTag("userID", value: (FIRAuth.auth()?.currentUser?.uid)!)
                databaseRef.updateChildValues(fanoutObject)

                print("Logging in as \(userID)")
                
                databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userData").observeSingleEvent(of: .value, with: { snapshot in
                
                    if snapshot.value is NSNull {
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "details")
                        self.present(nextViewController, animated: true, completion: nil)
                        
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "starting")
                        self.present(nextViewController, animated: true, completion: nil)
                    }
                })
                return
            })
        } */
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("logged out")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        registerButton.isEnabled = true
        myLoginButton.isEnabled = true
        emailLoginButton.isEnabled = true
        
        /*
        let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
        loginButton.center = view.center
        loginButton.delegate = self
        //loginButton.layer.cornerRadius = 7 */
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 180, height: 50))
        textView.textAlignment = .center
        
        textView.text = "S P I N"
        textView.font = UIFont(name: "Avenir-Light", size: 36)
        textView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)

        
        myLoginButton.backgroundColor = UIColor.white
        myLoginButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
        myLoginButton.center = view.center
        myLoginButton.setTitle("Login with Facebook", for: .normal)
        myLoginButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 14)
        myLoginButton.setTitleColor(UIColor(red: 29/255, green: 89/255, blue: 152/255, alpha: 1), for: .normal)
        myLoginButton.tintColor = UIColor(red: 29/255, green: 89/255, blue: 152/255, alpha: 1)
        myLoginButton.layer.borderColor = UIColor(red: 29/255, green: 89/255, blue: 152/255, alpha: 1).cgColor
        myLoginButton.layer.borderWidth = 1
        myLoginButton.layer.cornerRadius = 20
        
        emailLoginButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
        emailLoginButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 50)
        emailLoginButton.setTitleColor(UIColor.darkGray, for: .normal)
        emailLoginButton.layer.borderWidth = 1
        emailLoginButton.layer.borderColor = UIColor.darkGray.cgColor
        emailLoginButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 14)
        emailLoginButton.layer.cornerRadius = 20
        
        registerButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
        registerButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 100)
        registerButton.setTitleColor(UIColor.darkGray, for: .normal)
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor.darkGray.cgColor
        registerButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 14)
        registerButton.layer.cornerRadius = 20
        
        let textView2 = UITextView(frame: CGRect(x: 0, y: 0, width: 180, height: 50))
        textView2.text = "By pressing 'Login with Facebook' or 'Register' you agree to the Terms & Conditions that can be found at www.youngandvalley.com/terms"
        textView2.font = UIFont(name: "Avenir-Light", size: 8)
        textView2.isEditable = false
        textView2.isScrollEnabled = false
        textView2.textAlignment = .justified
        textView2.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 150)
        
        
        // Handle clicks on the button
        myLoginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        
        // Add the button to the view
        view.addSubview(myLoginButton)
        view.addSubview(textView)
        view.addSubview(textView2)
        
        //view.addSubview(loginButton)
    }
    
    func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success( _, _, _):
                self.myLoginButton.isHidden = true
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
                self.emailLoginButton.isEnabled = false
                self.emailLoginButton.isHidden = true
                self.registerButton.isEnabled = false
                self.registerButton.isHidden = true
                
                FIRAuth.auth()?.signIn(with: credential, completion: {
                    (user,error) in
                    
                    let databaseRef = FIRDatabase.database().reference()
                    
                    OneSignal.sendTag("userID", value: (FIRAuth.auth()?.currentUser?.uid)!)
                    
                    
                    OneSignal.promptLocation()
                    let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                    let userID = (status.subscriptionStatus.userId)!
                    
                    var fanoutObject: [String: AnyObject] = [:]
                    fanoutObject["/Users/\((FIRAuth.auth()?.currentUser?.uid)!)/userData/oneSignalKey"] = userID as AnyObject
                    fanoutObject["/OneSignalIDs/\((FIRAuth.auth()?.currentUser?.uid)!)"] = userID as AnyObject
                    OneSignal.sendTag("userID", value: (FIRAuth.auth()?.currentUser?.uid)!)
                    databaseRef.updateChildValues(fanoutObject)
                    
                    print("Logging in as \(userID)")
                    
                    databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userData").observeSingleEvent(of: .value, with: { snapshot in
                        
                        if snapshot.value is NSNull {
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let nextViewController = storyboard.instantiateViewController(withIdentifier: "details")
                            self.present(nextViewController, animated: true, completion: nil)
                            
                        } else {
                            let dict = snapshot.value as! [String: Any]
                            print(dict.count)
                            if dict.count > 5 {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let nextViewController = storyboard.instantiateViewController(withIdentifier: "starting")
                                self.present(nextViewController, animated: true, completion: nil)
                            } else {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let nextViewController = storyboard.instantiateViewController(withIdentifier: "details")
                                self.present(nextViewController, animated: true, completion: nil)
                            }
                        }
                    })
                    return
                })
            }
        }
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
