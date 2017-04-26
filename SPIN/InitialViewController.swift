//
//  InitialViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 12/12/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import FacebookCore
import FirebaseDatabase
import FirebaseAuth
import FacebookLogin

class InitialViewController: UIViewController {
    
    var tabViewController: TabViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(red: 41/255, green: 37/255, blue: 47/255, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Do any additional setup after loading the view.
        if AccessToken.current != nil {
            
            let registered = UserDefaults.standard
            
            if (registered.string(forKey: (FIRAuth.auth()?.currentUser?.uid)!) != nil) {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextViewController = storyboard.instantiateViewController(withIdentifier: "starting") as! TaskBarViewController

                nextViewController.modalTransitionStyle = .crossDissolve
                //self.tabViewController = nextViewController.topViewController as? TabViewController

                
                FIRDatabase.database().reference().child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userData").child("photoURL").setValue(FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)
                
                self.present(nextViewController, animated: true, completion: nil)
                
                
            } // Present the main screen
            else {
                
                let databaseRef = FIRDatabase.database().reference()
                databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userData").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.value is NSNull {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "details")
                        self.present(nextViewController, animated: true, completion: nil)
                    } //Take to the entering details screen
                    else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "starting") as! TaskBarViewController
                        
                        registered.set("Registered", forKey: (FIRAuth.auth()?.currentUser?.uid)!)
                        registered.synchronize()
                        nextViewController.modalTransitionStyle = .crossDissolve
                       //self.tabViewController = nextViewController.topViewController as? TabViewController
                        self.present(nextViewController, animated: true, completion: nil)
                    } //Register Key for user and present main screen
                })
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "introScreen")
            self.present(nextViewController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
