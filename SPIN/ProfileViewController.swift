//
//  ProfileViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 11/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import OneSignal

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePhoto: UIImageView?
    @IBOutlet weak var numberOfListings: UILabel!
    @IBOutlet weak var numberOfExchanges: UILabel!
    @IBOutlet weak var listingsLabel: UILabel!
    @IBOutlet weak var exchangesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var photosCollectionViewController: ProfileDressesCollectionView!
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var locationPin: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editNameField: UILabel!
    @IBOutlet weak var editBioField: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    static var uidToLoad: String = "self"
    static var ownUsername: String = "defaultusr"
    
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    
    var doNotDownload = false
    
    var profileToLoad: String! = "Pelayo Martinez"
    var photosRequiringLoading: [String] = []
    var previousController: ProfileViewController? = nil
    var noSettings = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        
        if editButton != nil {
            editButton.layer.borderWidth = 1
            editButton.layer.borderColor = UIColor.darkGray.cgColor
            editButton.layer.cornerRadius = 7
        }
        if logoutButton != nil {
            logoutButton.layer.borderWidth = 1
            logoutButton.layer.borderColor = UIColor.darkGray.cgColor
            logoutButton.layer.cornerRadius = 7
        }
        if messageButton != nil {
            messageButton.layer.borderWidth = 1
            messageButton.layer.borderColor = UIColor.darkGray.cgColor
            messageButton.layer.cornerRadius = 7
            messageButton.isEnabled = false
            messageButton.isHidden = true
        }
        if ProfileViewController.uidToLoad == (FIRAuth.auth()?.currentUser?.uid)! {
            messageButton.isHidden = true
            messageButton.isEnabled = false
        }
        if updateButton != nil {
            updateButton.layer.cornerRadius = 7
            updateButton.layer.borderWidth = 1
            updateButton.layer.borderColor = UIColor.darkGray.cgColor
        }
        if editBioField != nil {
            editBioField.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1).cgColor
            editBioField.layer.borderWidth = 1
            self.setDoneOnKeyboard()
        }
        
        navigationItem.title = ""
        
        
        let image2: UIImage = #imageLiteral(resourceName: "envelope")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        button2.addTarget(self, action: #selector(messageScreen), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: button2)
        //barButton2.addBadge(text: "\(BadgeHandler.messageBadgeNumber)")
        self.navigationItem.rightBarButtonItem = barButton2
        
        print(ProfileViewController.uidToLoad)
        print((FIRAuth.auth()?.currentUser?.uid)!)
        
        if !noSettings {
            let image3: UIImage = #imageLiteral(resourceName: "settings-5")
            let button3: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button3.setImage( image3, for: .normal)
            button3.addTarget(self, action: #selector(settingsScreen), for: .touchUpInside)
            
            let barButton3 = UIBarButtonItem(customView: button3)
            //barButton2.addBadge(text: "\(BadgeHandler.messageBadgeNumber)")
            self.navigationItem.leftBarButtonItem = barButton3
        }

        
        if photosCollectionViewController != nil {
            photosCollectionViewController.delegate2 = self
        }
        
        //loadProfile(username: profileToLoad)
        // Do any additional setup after loading the view.
        
        profilePhoto?.contentMode = .scaleAspectFill
        profilePhoto?.clipsToBounds = true
        profilePhoto?.layer.cornerRadius =  (profilePhoto?.frame.height)! / 2.0
        
        if !doNotDownload {
            downloadProfile(ref: ProfileViewController.uidToLoad)
        } else {
            if messageButton != nil {
                messageButton.isEnabled = true
                messageButton.isHidden = false
            }
        }
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.editBioField.inputAccessoryView = keyboardToolbar
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func settingsScreen() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settings")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        /*profilePhoto?.alpha = 0 //
        numberOfListings.alpha = 0 //
        numberOfExchanges.alpha = 0 //
        listingsLabel.alpha = 0 //
        exchangesLabel.alpha = 0 //
        locationLabel.alpha = 0 //
        self.editButton.alpha =0
        if bioTextView != nil {
            bioTextView.alpha = 0 //
        }
        if photosCollectionViewController != nil {
            photosCollectionViewController.alpha = 0
        }
        if profileUsername != nil {
            profileUsername.alpha = 0 //
        }
        locationPin.alpha = 0
 */
        if BadgeHandler.messageBadgeNumber != 0 {
            self.navigationItem.rightBarButtonItem?.setBadge(text: "\(BadgeHandler.messageBadgeNumber)")
        } else {
            self.navigationItem.rightBarButtonItem?.setBadge(text: "")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if photosCollectionViewController != nil {
            for cell in photosCollectionViewController.visibleCells {
                if cell.heroID != nil {
                    cell.heroID = ""
                }
            }
        }
        
        downloadTextData()
        /*
        bioTextView.center.x -= view.bounds.width
        profileUsername.center.x -= view.bounds.width
        listingsLabel.center.y += 30
        exchangesLabel.center.y += 30
        locationLabel.center.y += 30
        numberOfListings.center.y += 30
        numberOfExchanges.center.y += 30
        profilePhoto?.center.y -= 30
        locationPin.center.y += 30 */
        
        /*
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            //self.profilePhoto?.center.y += 30
            self.profilePhoto?.alpha = 1
            self.listingsLabel.alpha = 1
            self.numberOfListings.alpha = 1
            self.exchangesLabel.alpha = 1
            self.numberOfExchanges.alpha = 1
            self.locationLabel.alpha = 1
            self.locationPin.alpha = 1
            if self.profileUsername != nil {
                self.profileUsername.alpha = 1
                self.bioTextView.alpha = 1
                self.photosCollectionViewController.alpha = 1
            }
            self.editButton.alpha = 1

        }, completion: nil) */
        /*
        UIView.animate(withDuration: 0.2, delay: 0.1, options: [.curveEaseInOut], animations: {
            self.listingsLabel.center.y -= 30
            self.listingsLabel.alpha = 1
            self.numberOfListings.center.y -= 30
            self.numberOfListings.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [.curveEaseInOut], animations: {
            self.exchangesLabel.center.y -= 30
            self.exchangesLabel.alpha = 1
            self.numberOfExchanges.center.y -= 30
            self.numberOfExchanges.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [.curveEaseInOut], animations: {
            self.locationLabel.center.y -= 30
            self.locationLabel.alpha = 1
            self.locationPin.center.y -= 30
            self.locationPin.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [.curveEaseInOut], animations: {
            self.profileUsername.center.x += self.view.bounds.width
            self.profileUsername.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.4, options: [.curveEaseInOut], animations: {
            self.bioTextView.center.x += self.view.bounds.width
            self.bioTextView.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.5, options: [.curveEaseInOut], animations: {
            self.photosCollectionViewController.alpha = 1
        }, completion: nil) */
        
        profilePhoto?.layer.cornerRadius =  (profilePhoto?.frame.height)! / 2.0
        downloadPendingDresses()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*var totalHeight = CGFloat(0)
        for view in scrollView.subviews {
            totalHeight += view.bounds.height
        }
        let _ = scrollView.description
        let boundz = photosCollectionViewController.bounds
        photosCollectionViewController.bounds = CGRect(x: boundz.origin.x, y: boundz.origin.y, width: boundz.width, height: 1000)
        photosCollectionViewController.clipsToBounds = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1200) */
    }

    
    @IBAction func logOut(_ sender: Any) {
        
                
    }
    
    @IBAction func update(_ sender: Any) {
        let databaseRef = FIRDatabase.database().reference().child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userData")
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var downloadDict = snapshot.value as! [String: AnyObject]
            downloadDict["bio"] = self.editBioField.text as AnyObject
            databaseRef.setValue(downloadDict)
            self.previousController?.downloadTextData()
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        
        let theReference = FIRDatabase.database().reference()
        var alreadyThere = false
        (sender as! UIButton).isEnabled = false
        
        print("passed")
        
        if messageButton != nil {
            messageButton.backgroundColor = UIColor.darkGray
            messageButton.setTitleColor(UIColor.white, for: .normal)
            messageButton.isEnabled = false
        }
        
        theReference.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("conversations").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var conversationReference = ""
            
            let enumerator = snapshot.children
            while let nextChild = enumerator.nextObject() as? FIRDataSnapshot {
                
                let download = nextChild.value as! [String: Any]
                
                if download["uid"] as? String == ProfileViewController.uidToLoad {
                    alreadyThere = true
                    conversationReference = nextChild.key
                } else { alreadyThere = false }
            }
            
            if alreadyThere == true {
                print("there")
                let destinationNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "conversations") as! ChatNavigationController
                
                let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "chat") as! ChatViewController

                
                destinationViewController.senderDisplayName = Profile.ownUsername
                destinationViewController.senderId = (FIRAuth.auth()?.currentUser?.uid)!
                destinationViewController.refToLoad = conversationReference
                //TODO: Add URL image download
                destinationViewController.photoURL = "https://www.circuitlab.com/assets/images/gravatar_empty_50.png"
                destinationViewController.name = self.profileUsername.text!
                destinationViewController.uid = ProfileViewController.uidToLoad
                
                destinationNavigationController.pushViewController( destinationViewController, animated: true)
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.present(destinationNavigationController, animated: false, completion: nil)
                
            } else {
                //Create Conversation
                
                print("creatingConversation")
                
                let id = FIRDatabase.database().reference().child("Conversations").childByAutoId()
                id.child("timestamp").setValue(Int32(NSDate.timeIntervalSinceReferenceDate))
                
                let postOwn = ["id": id.key,
                            "uid": ProfileViewController.uidToLoad,
                            "name": self.profileUsername.text!,
                            "timestamp": Int32(NSDate.timeIntervalSinceReferenceDate),
                            "unseen": 0] as [String : Any]
                
                var postOther = postOwn
                postOther["name"] = Profile.ownUsername
                postOther["uid"] = (FIRAuth.auth()?.currentUser?.uid)!
                
                var fanoutObject: [String: Any] = [:]
                fanoutObject["/Users/\((FIRAuth.auth()?.currentUser?.uid)!)/conversations/\(id.key)"] =  postOwn
                fanoutObject["/Users/\(ProfileViewController.uidToLoad)/conversations/\(id.key)"] = postOther
                fanoutObject["/Conversations/\(id.key)/timestamp"] = Int(NSDate.timeIntervalSinceReferenceDate)
                
                print(fanoutObject)
                
                FIRDatabase.database().reference().updateChildValues(fanoutObject)
                
                
                
                let destinationNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "conversations") as! ChatNavigationController
                let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "chat") as! ChatViewController
            
                destinationViewController.senderDisplayName = Profile.ownUsername
                destinationViewController.senderId = (FIRAuth.auth()?.currentUser?.uid)!
                destinationViewController.refToLoad = id.key
                destinationViewController.name = self.profileUsername.text!
                destinationViewController.uid = ProfileViewController.uidToLoad
                
                destinationNavigationController.pushViewController( destinationViewController, animated: true)
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                if self.view.window != nil {
                    self.view.window!.layer.add(transition, forKey: kCATransition)
                }
                
                
                self.present(destinationNavigationController, animated: true, completion: nil)
                
                if self.messageButton != nil {
                    self.messageButton.backgroundColor = UIColor.white
                    self.messageButton.setTitleColor(UIColor.black, for: .normal)
                    self.messageButton.isEnabled = true
                    self.messageButton.isHidden = false
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "dressSegue2") {
            let svc = segue.destination as! MultipleDressScreenViewController;
            let dressSender = sender as! OwnDressesCollectionViewCell
            
            let _ = svc.view.description
            
            
            svc.isHeroEnabled = true
            self.isHeroEnabled = true
            self.navigationController?.isHeroEnabled = true
            
            dressSender.heroID = "imageTapped"
            svc.dressImagesCollectionView.heroID = "imageTapped"
            svc.profileName.heroModifiers = [.fade, .scale(0.5)]
            svc.locationLabel.heroModifiers = [.fade, .scale(0.5)]
            svc.profileImage.heroModifiers = [.fade, .scale(0.5)]
            svc.heroModalAnimationType = .auto
            self.heroModalAnimationType = .auto
            self.profilePhoto?.heroModifiers = [.fade]
            self.bioTextView.heroModifiers = [.fade]
            
            svc.refToLoad = dressSender.reference
            svc.uidToLoad = dressSender.uid
            svc.dressImagesCollectionView.currentPictures = []
            svc.dressImagesCollectionView.currentPictures.append(dressSender.cellImage.image!)
            
        } else if segue.identifier == "messageSegue" {
            
        } else if segue.identifier == "editProfile" {
            let svc = segue.destination as! ProfileViewController
            svc.doNotDownload = true
            let _ = svc.view.description
            svc.editNameField.text = self.profileUsername.text
            svc.editBioField.text = self.bioTextView.text
            svc.profilePhoto?.image = self.profilePhoto?.image
            svc.numberOfListings = self.numberOfListings
            svc.numberOfExchanges = self.numberOfExchanges
            svc.previousController = self
            self.locationLabel.text = self.locationLabel.text
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadTextData() {
        
        var currentUser: String = ""
        if ProfileViewController.uidToLoad == "self" {
            currentUser = (FIRAuth.auth()?.currentUser?.uid)!
        } else {
            currentUser = ProfileViewController.uidToLoad
        }
        
        let databaseRef = FIRDatabase.database().reference()
        
        //GET BIO, LISTINGS, EXCHANGES, USERNAME AND LOCATION
        
        databaseRef.child("Users").child(currentUser).child("userData").observeSingleEvent(of: .value, with: {
            snapshot in
            let downloadedDictionary = snapshot.value as! NSDictionary
            
            if self.photosCollectionViewController != nil {
                self.numberOfListings.text = "\(self.photosCollectionViewController.currentDresses.count)"
            } //downloadedDictionary["posts"] as? String
            self.numberOfExchanges.text = downloadedDictionary["exchanges"] as? String
            if self.bioTextView != nil {
                self.bioTextView.text = downloadedDictionary["bio"] as? String
            }
            self.locationLabel.text = downloadedDictionary["location"] as? String
            if self.profileUsername != nil {
                self.profileUsername.text = downloadedDictionary["username"] as? String
            }
            
            if downloadedDictionary["photoURL"] != nil {
                if let url = NSURL(string: downloadedDictionary["photoURL"] as! String) {
                    if let data = NSData(contentsOf: url as URL) {
                        self.profilePhoto?.image = UIImage(data: data as Data)!
                    }
                }
            }
            if self.messageButton != nil {
                self.messageButton.isEnabled = true
                self.messageButton.isHidden = false
            }
            
        })

    }
    
    func downloadProfile(ref: String) {
        
        let currentUser: String
        if ref == "self" {
            currentUser = (FIRAuth.auth()?.currentUser?.uid)!
            
        } else {
            currentUser = ref
        }
        
        let databaseRef = FIRDatabase.database().reference()
        let storageRef = FIRStorage.storage().reference()
        
        //GET BIO, LISTINGS, EXCHANGES, USERNAME AND LOCATION
        
        databaseRef.child("Users").child(currentUser).child("userData").observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.value != nil {
                let downloadedDictionary = snapshot.value as! NSDictionary
                print(currentUser)
                
                if self.photosCollectionViewController != nil {
                    self.numberOfListings.text = "\(self.photosCollectionViewController.currentDresses.count)"
                }
                self.numberOfExchanges.text = downloadedDictionary["exchanges"] as? String
                self.bioTextView.text = downloadedDictionary["bio"] as? String
                self.locationLabel.text = downloadedDictionary["location"] as? String
                self.profileUsername.text = downloadedDictionary["username"] as? String
                
                if downloadedDictionary["photoURL"] != nil {
                if let url = NSURL(string: downloadedDictionary["photoURL"] as! String) {
                        if let data = NSData(contentsOf: url as URL) {
                            self.profilePhoto?.image = UIImage(data: data as Data)!
                        }
                    }
                }
                if self.messageButton != nil {
                    self.messageButton.isEnabled = true
                    self.messageButton.isHidden = false
                }
            }

        })
        
        
        //GET UPLOADED IMAGES REFERENCES, DOWNLOAD THEM AND ADD THEM TO THE COLLECTION VIEW
        var dressRefArray: [String] = []
        
        databaseRef.child("Users").child(currentUser).child("dressesPosted").queryOrderedByValue().observe(.childAdded, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                print("empty")
            } else {
                
                let referenceMaster = snapshot.key
                dressRefArray.append(referenceMaster)
                
                self.photosCollectionViewController.currentDresses.insert((#imageLiteral(resourceName: "loading"), dressRefArray.last!, currentUser), at: 0)
                self.photosCollectionViewController.reloadData()
                
                storageRef.child("dressImages/\(referenceMaster)/1.jpg").data(withMaxSize: 2 * 1024 * 1024, completion: {
                    (data, error) in
                    
                    if error != nil {
                        print("error downloading image \(referenceMaster)")
                        self.photosRequiringLoading.append(referenceMaster)
                    } else {
                        for i in 0..<self.photosCollectionViewController.currentDresses.count {
                            if self.photosCollectionViewController.currentDresses[i].1 == referenceMaster {
                                if (data != nil) {
                                    self.photosCollectionViewController.currentDresses[i].0 = UIImage(data: data!)!
                                    self.photosCollectionViewController.reloadData()
                                }
                            }
                        }
                    }
                })
            }
        })
    }

    
    func downloadPendingDresses() {
        
        var toMaintainUnloaded: [String] = []
        let storageRef = FIRStorage.storage().reference()
        for item in photosRequiringLoading {
            storageRef.child("dressImages/\(item)/1.jpg").data(withMaxSize: 2 * 1024 * 1024, completion: {
                (data, error) in
                
                if error != nil {
                    print("error downloading \(item)")
                    toMaintainUnloaded.append(item)
                    
                } else {
                    for i in 0..<self.photosCollectionViewController.currentDresses.count {
                        if self.photosCollectionViewController.currentDresses[i].1 == item {
                            if data != nil {
                                self.photosCollectionViewController.currentDresses[i].0 = UIImage(data: data!)!
                                self.photosCollectionViewController.reloadData()
                            }
                        }
                    }
                }
                if self.photosCollectionViewController != nil {
                    self.numberOfListings.text = "\(self.photosCollectionViewController.currentDresses.count)"
                }
            })
        }
        photosRequiringLoading = toMaintainUnloaded
        if self.photosCollectionViewController != nil {
            self.numberOfListings.text = "\(self.photosCollectionViewController.currentDresses.count)"
        }
    }
    
}

extension ProfileViewController: LongPressDelegate {
    
    func updateSize(size: Int) {
        
            collectionHeightConstraint.constant = CGFloat(size)
            scrollView.sizeToFit()
        
    }
    
    func updateListings() {
        if self.photosCollectionViewController != nil {
            self.numberOfListings.text = "\(self.photosCollectionViewController.currentDresses.count)"
        }
    }
    
    func didLongPressCell(sender: UIGestureRecognizer) {
        
        let databaseRef = FIRDatabase.database().reference()
        
        if sender.state == .began {
            
            let cell = sender.view as! OwnDressesCollectionViewCell
            print("cell.reference = \(cell.reference)")
            
            let alert = UIAlertController(title: "Options", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    
                    databaseRef.child("Posts").child(cell.reference).child("numberOfImages").observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.value is NSNull {
                                //Remove from posts and remove from Posts Node
                                databaseRef.child("Posts").child(cell.reference).removeValue()
                                
                                //Remove from the users dressesPosted
                                databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("dressesPosted").child(cell.reference).removeValue()

                            } else {
                                let numberToDelete = snapshot.value as! Int
                                
                                //Delete all images in post
                                for i in 0..<numberToDelete {
                                    print(i)
                                    FIRStorage.storage().reference().child("dressImages").child("\(cell.reference)").child("\(i+1).jpg").delete(completion: { (error) in
                                            if let error = error {
                                                print(error.localizedDescription)
                                            } else {
                                                print("Success!")
                                            }
                                        })
                                }
                                //Remove from posts and remove from Posts Node
                                databaseRef.child("Posts").child(cell.reference).removeValue()
                                
                                //Remove from the users dressesPosted
                                databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("dressesPosted").child(cell.reference).removeValue()

                        }})
                                
                        //Remove from savedDresses for everyone who liked it
                        databaseRef.child("PostData").child(cell.reference).child("swipedRight").observeSingleEvent(of: .value, with:
                            { (snapshot) in
                                        
                                if snapshot.value is NSNull {
                                    self.photosCollectionViewController.currentDresses.remove(at: (self.photosCollectionViewController.indexPath(for: cell)?.row)!)
                                    self.photosCollectionViewController.reloadData()

                                } else {
                                    let downloadArray = snapshot.value as! [String: NSNumber]
                                    
                                    for (user, _) in downloadArray {
                                        
                                        databaseRef.child("Users").child(user).child("savedDresses").child(cell.reference).removeValue()
                                        
                                    }
                                    databaseRef.child("PostData").child(cell.reference).removeValue()
                                    self.photosCollectionViewController.currentDresses.remove(at: (self.photosCollectionViewController.indexPath(for: cell)?.row)!)
                                    
                                    self.photosCollectionViewController.reloadData()
                                }
                        })
                            
                        databaseRef.child("RequestData").child(cell.reference).observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.value is NSNull {
                                print("no requests for this dress")
                            } else {
                                let downloadArray = snapshot.value as! [String: String]
                                for (user, _) in downloadArray {
                                    print("getting rid in users \(user)")
                                    let maquery = databaseRef.child("Users").child(user).child("outgoingRequests").queryOrdered(byChild: "dressReference").queryEqual(toValue: cell.reference)
                                        print(maquery)
                                        maquery.observeSingleEvent(of: .childAdded, with: { (snapshot) in
                                            
                                            databaseRef.child("Users").child(user).child("outgoingRequests").child(snapshot.key).removeValue()
                                    })

                                }
                            }
                        })
                        
                        let query1 = databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("incomingRequests").queryOrdered(byChild: "dressReference").queryEqual(toValue: cell.reference)
                        
                            print(query1.description)
                        
                            query1.observeSingleEvent(of: .childAdded, with: { (snapshot) in
                            print(snapshot.key)
                                databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("incomingRequests").child(snapshot.key).removeValue()
                            
                        })
                        
                                
                        //Decrease the "Posts" number by 1
                        
                        databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userData").child("posts").setValue(String(self.photosCollectionViewController.currentDresses.count - 1))
                    
                    self.photosCollectionViewController.reloadData()
                }
            }))
                
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
                switch action.style{
                case .cancel: break
                    
                default: break
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

