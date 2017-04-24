//
//  detailesViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 19/12/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import OneSignal

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitDetails(_ sender: Any) {
        var ready = [false, false, false]
        
        if usernameTextField.text == "" {
            showPopUp(missingField: "a username")
            ready[0] = false
        } else {
            ready[0] = true
        }
        
        if ready[0] == true {
            if bioTextView.text == "" || bioTextView.text == "Enter text..." {
                showPopUp(missingField: "your bio")
                ready[1] = false
            } else {
                ready[1] = true
            }
        }
        if ready[0] == true && ready[1] == true {
            if locationTextField.text == "" {
                showPopUp(missingField: "your location")
                ready[2] = false
            } else {
                ready[2] = true
            }
        }
        
        if ready[0] == true && ready[1] == true && ready[2] == true {
            
            uploadData()
        }
    }
    func showPopUp(missingField: String) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popup") as! PopViewController
            self.addChildViewController(vc)
            vc.view.frame = self.view.frame
            self.view.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        
        UIView.animate(withDuration: 0.4, animations: {
            vc.message.alpha = 1
            vc.button.alpha = 1
            vc.theView.alpha = 1
        })
        
        vc.message.text = "Please enter \(missingField)"
    }
    
    func uploadData() {
        
        print((FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)!)
        
        var profileImage = UIImage()
        if let data = NSData(contentsOf: NSURL(string: (FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)!)! as URL) {
            profileImage = UIImage(data: data as Data)!
        }
        
        var imageData = UIImageJPEGRepresentation(profileImage, 0.5)
        
        if imageData != nil {
            uploadImageToDatabase(data: imageData!)
        } else {
            imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "loading"), 0.5)
            uploadImageToDatabase(data: imageData!)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "starting")
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    func uploadImageToDatabase(data: Data)
    {
        let username = (FIRAuth.auth()?.currentUser?.uid)!
        let storageRef = FIRStorage.storage().reference().child("profileImages/\(username).jpg")
        let databaseRef = FIRDatabase.database().reference()// Bio, exchanges, location, photoURL, posts, username
        
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        storageRef.put(data, metadata: uploadMetadata, completion: {
            (metadata, error) in
            if(error != nil) {
                print("Enconuntered an error \(String(describing: error?.localizedDescription))")
            }
            else {
                print("Upload Complete")
                
                let url = (metadata?.downloadURL())!
                let newDict = ["bio": self.bioTextView.text! as String,
                               "exchanges": "0",
                               "location": self.locationTextField.text! as String,
                               "photoURL": url.absoluteString as String,
                               "posts": "0",
                               "username": self.usernameTextField.text! as String]
                
                OneSignal.sendTag("userID", value: username)

                databaseRef.child("Users").child(username).child("userData").setValue(newDict)
                
                databaseRef.child("Users").child(username).child("userData").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.value is NSNull {   } else {
                        let registered = UserDefaults.standard
                        registered.setValue("Registered", forKey: username)
                        registered.synchronize()
                    }
                })
            }
        })
    }
}
