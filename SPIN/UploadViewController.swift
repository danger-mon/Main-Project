//
//  UploadViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 22/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import OneSignal

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var dressNameField: UITextField!
    @IBOutlet weak var dressDescriptionField: UITextView!
    @IBOutlet weak var rentSellSegmentedControl: UISegmentedControl!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var uploadCollectionView: MultipleDressCollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    //NOT USED:
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var rentSellTitle: UILabel!
    @IBOutlet weak var priceTitle: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    var imageSelected: UIImage? = nil
    var toWhatCell: Int = 0
    var imageCount = 0
    var imageCountShadow = 0
    var refToLoad = ""
    
    @IBAction func doneEditting(_ sender: Any) {
        dressDescriptionField.resignFirstResponder()
        
    }
    
    let imagePicker = UIImagePickerController()
    var lastKey: String = ""
    var post : [String: AnyObject] = [:]
    var photoURL = ""
    var timestamp: Double = NSDate.timeIntervalSinceReferenceDate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionButton.isEnabled = true
        if deleteButton != nil {
            deleteButton.isEnabled = true
        }
        
        dressDescriptionField.delegate = self
        dressDescriptionField.text = "Tap to edit..."
        dressDescriptionField.textColor = UIColor.lightGray
        dressDescriptionField.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1).cgColor
        dressDescriptionField.layer.borderWidth = 1
        dressDescriptionField.layer.cornerRadius = 5
        dressDescriptionField.backgroundColor = UIColor.white
        
        actionButton.layer.borderColor = UIColor.lightGray.cgColor
        actionButton.layer.borderWidth = 1
        actionButton.layer.cornerRadius = 7
        
        if deleteButton != nil {
            deleteButton.layer.borderColor = UIColor.red.cgColor
            deleteButton.layer.borderWidth = 1
            deleteButton.layer.cornerRadius = 7
        }
        
        dressNameField.delegate = self
        priceField.delegate = self
        actionButton.superview?.bringSubview(toFront: actionButton)
        self.view.bringSubview(toFront: actionButton)
        
        let image2: UIImage = #imageLiteral(resourceName: "envelope")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        button2.addTarget(self, action: #selector(messageScreen), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: button2)
        self.navigationItem.rightBarButtonItem = barButton2

        
        uploadCollectionView.currentPictures = [#imageLiteral(resourceName: "placeholderImage"), #imageLiteral(resourceName: "placeholderImage"), #imageLiteral(resourceName: "placeholderImage"), #imageLiteral(resourceName: "placeholderImage")]
        uploadCollectionView.isItUpload = true
        if heightConstraint != nil {
            heightConstraint.constant = UIScreen.main.bounds.width / 4
        }
        uploadCollectionView.isPagingEnabled = false
        uploadCollectionView.isScrollEnabled = false
        //scrollView.contentSize.height = 1000
        //uploadCollectionView.bounds.height = UIScreen.main.bounds.width
        
        //scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        imagePicker.delegate = self
        
    }
    

    
    func messageScreen() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "conversations")
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(vc!, animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if BadgeHandler.messageBadgeNumber != 0 {
        self.navigationItem.rightBarButtonItem?.setBadge(text: "\(BadgeHandler.messageBadgeNumber)")
        } else {
            self.navigationItem.rightBarButtonItem?.setBadge(text: "")
        }
        /*
        nameTitle.isHidden = true
        dressNameField.isHidden = true
        descriptionTitle.isHidden = true
        dressDescriptionField.isHidden = true
        rentSellTitle.isHidden = true
        priceTitle.isHidden = true
        doneButton.isHidden = true
        rentSellSegmentedControl.isHidden = true
        priceField.isHidden = true
        uploadCollectionView.isHidden = true */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: 694)
        self.nameTitle.center.x -= self.view.bounds.width
        dressNameField.center.x -= view.bounds.width
        descriptionTitle.center.x -= view.bounds.width
        dressDescriptionField.center.x -= view.bounds.width
        rentSellTitle.center.x -= view.bounds.width
        priceTitle.center.x -= view.bounds.width
        doneButton.center.x -= view.bounds.width
        rentSellSegmentedControl.center.x -= view.bounds.width
        priceField.center.x -= view.bounds.width
        uploadCollectionView.center.x -= view.bounds.width
        
        nameTitle.isHidden = false
        dressNameField.isHidden = false
        descriptionTitle.isHidden = false
        dressDescriptionField.isHidden = false
        rentSellTitle.isHidden = false
        priceTitle.isHidden = false
        doneButton.isHidden = false
        rentSellSegmentedControl.isHidden = false
        priceField.isHidden = false
        uploadCollectionView.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
           //self.uploadTitle.center.y += 100
        }
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
            self.nameTitle.center.x += self.view.bounds.width
            self.dressNameField.center.x += self.view.bounds.width
        }, completion: nil)
        UIView.animate(withDuration: 0.3, delay: 0.6, options: [], animations: {
            self.descriptionTitle.center.x += self.view.bounds.width
            self.dressDescriptionField.center.x += self.view.bounds.width
            self.doneButton.center.x += self.view.bounds.width
        }, completion: nil)
        UIView.animate(withDuration: 0.3, delay: 0.9, options: [], animations: {
            self.rentSellTitle.center.x += self.view.bounds.width
            self.rentSellSegmentedControl.center.x += self.view.bounds.width
        }, completion: nil)
        UIView.animate(withDuration: 0.3, delay: 1.2, options: [], animations: {
            self.priceTitle.center.x += self.view.bounds.width
            self.priceField.center.x += self.view.bounds.width
        }, completion: nil)
        UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
            self.uploadCollectionView.center.x += self.view.bounds.width
        }, completion: nil)
        UIView.animate(withDuration: 0.3, delay: 1.8, options: [], animations: {
            //self.actionButton.center.x += self.view.bounds.width
        }, completion: nil)
        
 */
    }
    
    @IBAction func deletePost(_ sender: Any) {
        
        let databaseRef = FIRDatabase.database().reference()
        
        databaseRef.child("Posts").child(self.refToLoad).child("numberOfImages").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                //Remove from posts and remove from Posts Node
                databaseRef.child("Posts").child(self.refToLoad).removeValue()
                
                //Remove from the users dressesPosted
                databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("dressesPosted").child(self.refToLoad).removeValue()
                
            } else {
                let numberToDelete = snapshot.value as! Int
                
                //Delete all images in post
                for i in 0..<numberToDelete {
                    print(i)
                    FIRStorage.storage().reference().child("dressImages").child("\(self.refToLoad)").child("\(i+1).jpg").delete(completion: { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("Success!")
                        }
                    })
                }
                
                //Remove from posts and remove from Posts Node
                databaseRef.child("Posts").child(self.refToLoad).removeValue()
                
                //Remove from the users dressesPosted
                databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("dressesPosted").child(self.refToLoad).removeValue()

            }})
        
        //Remove from savedDresses for everyone who liked it
        databaseRef.child("PostData").child(self.refToLoad).child("swipedRight").observeSingleEvent(of: .value, with:
            { (snapshot) in
                
                if snapshot.value is NSNull {
                    
                    
                } else {
                    let downloadArray = snapshot.value as! [String: NSNumber]
                    
                    for (user, _) in downloadArray {
                        
                        databaseRef.child("Users").child(user).child("savedDresses").child(self.refToLoad).removeValue()
                        
                    }
                    databaseRef.child("PostData").child(self.refToLoad).removeValue()
                }
        })
        
        databaseRef.child("RequestData").child(self.refToLoad).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("no requests for this dress")
            } else {
                let downloadArray = snapshot.value as! [String: String]
                for (user, _) in downloadArray {
                    print("getting rid in users \(user)")
                    let maquery = databaseRef.child("Users").child(user).child("outgoingRequests").queryOrdered(byChild: "dressReference").queryEqual(toValue: self.refToLoad)
                    print(maquery)
                    maquery.observeSingleEvent(of: .childAdded, with: { (snapshot) in
                        
                        databaseRef.child("Users").child(user).child("outgoingRequests").child(snapshot.key).removeValue()
                    })
                    
                }
            }
        })
        
        let query1 = databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("incomingRequests").queryOrdered(byChild: "dressReference").queryEqual(toValue: self.refToLoad)
        
        print(query1.description)
        
        query1.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            print(snapshot.key)
            databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("incomingRequests").child(snapshot.key).removeValue()
            
        })
        
        
        //Decrease the "Posts" number by 1
        
    }

    @IBOutlet weak var insideView: UIView!

    override func viewDidLayoutSubviews() {
        
        var recognisers: [UITapGestureRecognizer] = []
        for _ in 0..<4 {
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(UploadViewController.imageTapped(sender:)))
            tapGestureRecognizer.delegate = self
            recognisers.append(tapGestureRecognizer)
        }
        uploadCollectionView.areCellsInteractable = true
        uploadCollectionView.tapRecognisers = recognisers
        
        if self.scrollView != nil {
            self.scrollView.sizeToFit()
            
            
        }
        if insideView != nil {
            insideView.sizeToFit()
            scrollView.sizeToFit()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: uploadCollectionView)
        let indexPath = self.uploadCollectionView.indexPathForItem(at: tapLocation)
        toWhatCell = (self.uploadCollectionView.cellForItem(at: indexPath!) as! MultipleDressCollectionViewCell).id
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func changeImage() {
        uploadCollectionView.currentPictures[toWhatCell] = imageSelected!
        uploadCollectionView.reloadData()
        imageCount += 1
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            imageSelected = possibleImage
            self.changeImage()
            dismiss(animated: true, completion: nil)
        }
        else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imageSelected = possibleImage
            self.changeImage()
            dismiss(animated: true, completion: nil)
        }
        else {
            dismiss(animated: true, completion: nil)}
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    //Post and update methods are basically using the same three functions but I copied and pasted cos im lazy.
    //TODO: Clean this mess up
    @IBAction func update(_ sender: Any) {
        print("e;;p")
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
        
        var checker: (Bool, Bool, Bool) = (true, true, true)
        
        if dressNameField.text == "" {
            checker.0 = true
        } else { checker.0 = false }
        if dressDescriptionField.text == "" || dressDescriptionField.text == "Tap to edit..." {
            checker.1 = true
        } else { checker.1 = false }
        if priceField.text == "" {
            checker.2 = true
        } else { checker.2 = false }
        
        if checker.0 == false && checker.1 == false && checker.2 == false {
            imageCountShadow = 4//imageCount
            for m in 0..<self.uploadCollectionView.currentPictures.count {
                if self.uploadCollectionView.currentPictures[m] == #imageLiteral(resourceName: "placeholderImage"){
                    imageCountShadow -= 1
                }
            }
            
            updateItem()
            
        } else if checker.0 == true {
            alert.message = "Please enter a dress name"
            self.present(alert, animated: true, completion: nil)
        } else if checker.1 == true {
            alert.message = "Please enter a description for your dress"
            self.present(alert, animated: true, completion: nil)
        } else if checker.2 == true {
            alert.message = "Please enter a price"
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        print("Submit")
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
        
        var checker: (Bool, Bool, Bool) = (true, true, true)
        
        if dressNameField.text == "" {
            checker.0 = true
        } else { checker.0 = false }
        if dressDescriptionField.text == "" || dressDescriptionField.text == "Tap to edit..." {
            checker.1 = true
        } else { checker.1 = false }
        if priceField.text == "" {
            checker.2 = true
        } else { checker.2 = false }
        
        if checker.0 == false && checker.1 == false && checker.2 == false {
            imageCountShadow = imageCount
            postItem()
            dressNameField.text = ""
            dressDescriptionField.text = "Tap to edit..."
            priceField.text = ""
            for i in 0..<uploadCollectionView.currentPictures.count {
                uploadCollectionView.currentPictures[i] = #imageLiteral(resourceName: "placeholderImage")
            }
            uploadCollectionView.reloadData()
            
            toWhatCell = 0
            imageSelected = #imageLiteral(resourceName: "placeholderImage")
            imageCount = 0
            
        } else if checker.0 == true {
            alert.message = "Please enter a dress name"
            self.present(alert, animated: true, completion: nil)
        } else if checker.1 == true {
            alert.message = "Please enter a description for your dress"
            self.present(alert, animated: true, completion: nil)
        } else if checker.2 == true {
            alert.message = "Please enter a price"
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    func postItem() {
        
        actionButton.isEnabled = false
        deleteButton.isEnabled = true
        
        let user = (FIRAuth.auth()?.currentUser?.uid)!
        let title = dressNameField.text
        let dressDescription = dressDescriptionField.text
        var rentSell: String
        if rentSellSegmentedControl.selectedSegmentIndex == 0 {
            rentSell = "rent"
        }
        else {
            rentSell = "sell"
        }
        let price = priceField.text
        let databaseRef = FIRDatabase.database().reference()
        var imageDataArray: [Data] = []
        for i in 0..<imageCountShadow {
            let imageData = UIImageJPEGRepresentation(self.uploadCollectionView.currentPictures[i], 0.3)
            imageDataArray.append(imageData!)
        }
        
        databaseRef.child("Users").child(user).child("userData").child("photoURL").observeSingleEvent(of: .value, with: {
            (snapshot) in
            self.photoURL = (snapshot.value)! as! String
            self.post = ["title": title as AnyObject,
                    "description" : dressDescription as AnyObject,
                    "rentSell": rentSell as AnyObject,
                    "price": price as AnyObject,
                    "numberOfImages": self.imageCountShadow as AnyObject,
                    "username": Profile.ownUsername as AnyObject,
                    "uid": user as AnyObject,
                    "profilePhotoURL": self.photoURL as AnyObject,
                    "timestamp": NSDate().timeIntervalSinceReferenceDate as AnyObject]
            
            let postRefKey = databaseRef.child("Posts").childByAutoId()
            
            self.uploadImageToDatabse(data: imageDataArray, id: postRefKey, user: user, post: self.post, changeTime: true)
        })
        
    }
    
    func uploadImageToDatabse(data: [Data], id: FIRDatabaseReference, user: String, post: [String: AnyObject], changeTime: Bool)
    {
        
        let storageRef = FIRStorage.storage().reference().child("dressImages/\(id.key)")
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        let counter = data.count
        imageCountShadow = 0
        for i in 0..<counter {
            
            storageRef.child("\(i + 1).jpg").put(data[i], metadata: uploadMetadata, completion: {
                (metadata, error) in
                if(error != nil) {
                    print("I received an error! \(String(describing: error?.localizedDescription))")
                }
                else{
                    print("Upload Complete! Here's some metadata \(String(describing: metadata))")
                    
                    let databaseRef = FIRDatabase.database().reference()
                    databaseRef.child("Users").child(user).child("userData").child("location").observeSingleEvent(of: .value, with: { (snapshot) in
                        var newPost = post
                        newPost["location"] = snapshot.value as AnyObject?
                        databaseRef.child("Users").child(user).child("userData").child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
                            let numberOfListings = snapshot.value as! String
                            var numberOfListingsInt = Int(numberOfListings)!
                            numberOfListingsInt += 1
                            databaseRef.child("Posts").child(id.key).setValue(newPost)
                            databaseRef.child("Users").child(user).child("userData").child("posts").setValue(String(numberOfListingsInt))
                            (self.tabBarController?.viewControllers?[1] as! UINavigationController).popToRootViewController(animated: true)
                            self.tabBarController?.selectedIndex = 1
                        })
                    })
                    
                    if changeTime {
                        
                        databaseRef.child("Users").child(user).child("dressesPosted").child(id.key).setValue( Int32(NSDate.timeIntervalSinceReferenceDate))
                    }
                }
            })
        }
    }
    
    func updateItem() {
        
        actionButton.isEnabled = false
        deleteButton.isEnabled = false
        
        //imageCountShadow = uploadCollectionView.currentPictures.count
        let user = (FIRAuth.auth()?.currentUser?.uid)!
        let title = dressNameField.text
        let dressDescription = dressDescriptionField.text
        var rentSell: String
        if rentSellSegmentedControl.selectedSegmentIndex == 0 {
            rentSell = "rent"
        }
        else {
            rentSell = "sell"
        }
        let price = priceField.text
        let databaseRef = FIRDatabase.database().reference()
        var imageDataArray: [Data] = []
        for i in 0..<imageCountShadow {
            let imageData = UIImageJPEGRepresentation(self.uploadCollectionView.currentPictures[i], 0.3)
            imageDataArray.append(imageData!)
        }
        
        databaseRef.child("Users").child(user).child("userData").child("photoURL").observeSingleEvent(of: .value, with: {
            (snapshot) in
            self.photoURL = (snapshot.value)! as! String
            self.post = ["title": title as AnyObject,
                         "description" : dressDescription as AnyObject,
                         "rentSell": rentSell as AnyObject,
                         "price": price as AnyObject,
                         "numberOfImages": self.imageCountShadow as AnyObject,
                         "username": Profile.ownUsername as AnyObject,
                         "uid": user as AnyObject,
                         "profilePhotoURL": self.photoURL as AnyObject,
                         "timestamp": self.timestamp as AnyObject]
            
            let postRefKey = databaseRef.child("Posts").child(self.refToLoad)
            
            self.uploadImageToDatabse(data: imageDataArray, id: postRefKey, user: user, post: self.post, changeTime: false)
            
            self.dressNameField.text = ""
            self.dressDescriptionField.text = "Tap to edit..."
            self.priceField.text = ""
            for i in 0..<self.uploadCollectionView.currentPictures.count {
                self.uploadCollectionView.currentPictures[i] = #imageLiteral(resourceName: "placeholderImage")
            }
            self.toWhatCell = 0
            self.imageSelected = #imageLiteral(resourceName: "placeholderImage")
            self.imageCount = 0
        })
        
    }

}

extension UploadViewController {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.textColor = UIColor.black
            if textView.text == "Tap to edit..." {
                textView.text = ""
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tap to edit..."
            textView.textColor = UIColor.lightGray
        }
    }
}
