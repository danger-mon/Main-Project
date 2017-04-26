//
//  regsiterViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 24/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import OneSignal

class RegsiterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioTextField: UITextView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        bioTextField.layer.cornerRadius = 7
        bioTextField.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1).cgColor
        bioTextField.layer.borderWidth = 1
        
        submitButton.layer.cornerRadius = 7
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.darkGray.cgColor
        
        profileImageView.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1).cgColor
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    override func viewDidLayoutSubviews() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(imageTapped(sender:)))
        tapGestureRecognizer.delegate = self
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        profileImageView.isUserInteractionEnabled = true
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        print("yo")
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profileImageView.image = possibleImage
            dismiss(animated: true, completion: nil)
        }
        else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            profileImageView.image = possibleImage
            dismiss(animated: true, completion: nil)
        }
        else {
            dismiss(animated: true, completion: nil)}
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(_ sender: Any) {
        var ready = [false, false, false, false, false]
        if usernameField.text == "" {
            showPopUp(missingField: "a username")
            ready[0] = false
        } else {
            ready[0] = true
        }
        if bioTextField.text == "" {
            showPopUp(missingField: "your bio")
            ready[1] = false
        } else {
            ready[1] = true
        }
        if locationField.text == "" {
            showPopUp(missingField: "your location")
            ready[2] = false
        } else {
            ready[2] = true
        }
        if passwordField.text == "" {
            showPopUp(missingField: "a password")
            ready[4] = false
        } else {
            ready[4] = true
        }
        if emailField.text == "" {
            showPopUp(missingField: "a valid email")
            ready[3] = false
        } else {
            if isValidEmail(testStr: emailField.text!) {
                ready[3] = true
            }
        }
        if ready[0] == true && ready[1] == true && ready[2] == true && ready[3] == true && ready[4] == true {
            print("123")
            createUser(email: emailField.text!, password: passwordField.text!)
        }
    }
    
    func createUser(email: String, password: String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print("Success")
                let changeRequest = user?.profileChangeRequest()
                
                changeRequest?.displayName = self.usernameField.text!
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print("Error changin displayName")
                    } else {
                        self.uploadData(user: user!)
                    }
                }
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
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
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func uploadData(user: FIRUser) {
        let uid = user.uid
        let storageRef = FIRStorage.storage().reference().child("profileImages/\(uid).jpg")
        let databaseRef = FIRDatabase.database().reference()
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        var imageData = UIImageJPEGRepresentation(profileImageView.image!, 0.5)
        
        storageRef.put(imageData!, metadata: uploadMetadata, completion: {
            (metadata, error) in
            if(error != nil) {
                print("Enconuntered an error \(String(describing: error?.localizedDescription))")
            }
            else {
                print("Upload Complete")
                
                let url = (metadata?.downloadURL())!
                let newDict = ["bio": self.bioTextField.text! as String,
                               "exchanges": "0",
                               "location": self.locationField.text! as String,
                               "photoURL": url.absoluteString as String,
                               "posts": "0",
                               "username": self.usernameField.text! as String]
                
                OneSignal.sendTag("userID", value: uid)
                
                var fanoutObject: [String: [String: Any]] = [:]
                
                fanoutObject["/Users/\(uid)/userData"] = newDict
                databaseRef.updateChildValues(fanoutObject)
                databaseRef.child("Users").child(uid).child("userData").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.value is NSNull {
                        self.showPopUp(missingField: "Couldn't make an account, please try again later")
                    } else {
                        let registered = UserDefaults.standard
                        registered.setValue("Registered", forKey: uid)
                        registered.synchronize()
                        //Add onesignal stuff
                        
                        OneSignal.promptLocation()
                        
                        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                        let userID = (status.subscriptionStatus.userId)!
                        
                        var fanoutObject2: [String: AnyObject] = [:]
                        fanoutObject2["/Users/\(uid)/userData/oneSignalKey"] = userID as AnyObject
                        fanoutObject2["/OneSignalIDs/\(uid)"] = userID as AnyObject
                        OneSignal.sendTag("userID", value: uid)
                        
                        databaseRef.updateChildValues(fanoutObject2)
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "starting")
                        self.present(nextViewController, animated: true, completion: nil)
                    }
                })
            }
        })

    }
}
