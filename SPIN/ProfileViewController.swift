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
    @IBOutlet weak var editNameField: UITextField!
    @IBOutlet weak var editBioField: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    static var uidToLoad: String = "self"
    static var ownUsername: String = "defaultusr"
    
    var doNotDownload = false
    
    var profileToLoad: String! = "Pelayo Martinez"
    var photosRequiringLoading: [String] = []
    var previousController: ProfileViewController? = nil
    
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
        }
        
        navigationItem.title = ""
        
        let image2: UIImage = #imageLiteral(resourceName: "envelope")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        button2.addTarget(self, action: #selector(messageScreen), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: button2)
        self.navigationItem.rightBarButtonItem = barButton2
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
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        profilePhoto?.alpha = 0 //
        numberOfListings.alpha = 0 //
        numberOfExchanges.alpha = 0 //
        listingsLabel.alpha = 0 //
        exchangesLabel.alpha = 0 //
        locationLabel.alpha = 0 //
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
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

        }, completion: nil)
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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "login")
        self.present(nextViewController, animated: true, completion: nil)
        
        let loginManager = LoginManager()
        loginManager.logOut()
        
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
                
                let destinationNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "conversations") as! ChatNavigationController
                
                let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "chat") as! ChatViewController

                
                destinationViewController.senderDisplayName = Profile.ownUsername
                destinationViewController.senderId = (FIRAuth.auth()?.currentUser?.uid)!
                destinationViewController.refToLoad = conversationReference
                //TODO: Add URL image download
                destinationViewController.photoURL = "https://www.circuitlab.com/assets/images/gravatar_empty_50.png"
                destinationViewController.name = self.profileUsername.text!
                
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
                
                var post = ["id": id.key,
                            "uid": ProfileViewController.uidToLoad,
                            "name": self.profileUsername.text!,
                            "photoURL": "https://www.circuitlab.com/assets/images/gravatar_empty_50.png",
                            "timestamp": Int32(NSDate.timeIntervalSinceReferenceDate)] as [String : Any]
                
                //Add to senders conversations
                FIRDatabase.database().reference().child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("conversations").child(id.key).setValue(post)
                
                //Change the 'opposite name' and add to the receivers conversation
                post["name"] = Profile.ownUsername
                
                FIRDatabase.database().reference().child("Users").child(ProfileViewController.uidToLoad).child("conversations").child(id.key).setValue(post)
                
                let destinationNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "conversations") as! ChatNavigationController
            
                let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "chat") as! ChatViewController
            
                destinationViewController.senderDisplayName = Profile.ownUsername
                destinationViewController.senderId = (FIRAuth.auth()?.currentUser?.uid)!
                destinationViewController.refToLoad = id.key
                //TODO: Add URL image download
                destinationViewController.photoURL = "https://www.circuitlab.com/assets/images/gravatar_empty_50.png"
                destinationViewController.name = self.profileUsername.text!
            
                destinationNavigationController.pushViewController( destinationViewController, animated: true)
                self.present(destinationNavigationController, animated: true, completion: nil)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "dressSegue2") {
            let svc = segue.destination as! MultipleDressScreenViewController;
            let dressSender = sender as! OwnDressesCollectionViewCell
            
            let _ = svc.view.description
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
        self.present(vc!, animated: true, completion: nil)
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
            
            self.numberOfListings.text = downloadedDictionary["posts"] as? String
            self.numberOfExchanges.text = downloadedDictionary["exchanges"] as? String
            self.bioTextView.text = downloadedDictionary["bio"] as? String
            self.locationLabel.text = downloadedDictionary["location"] as? String
            self.profileUsername.text = downloadedDictionary["username"] as? String
            let url = NSURL(string: downloadedDictionary["photoURL"] as! String)
            if let data = NSData(contentsOf: url! as URL) {
                self.profilePhoto?.image = UIImage(data: data as Data)!
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
            let downloadedDictionary = snapshot.value as! NSDictionary
            
            self.numberOfListings.text = downloadedDictionary["posts"] as? String
            self.numberOfExchanges.text = downloadedDictionary["exchanges"] as? String
            self.bioTextView.text = downloadedDictionary["bio"] as? String
            self.locationLabel.text = downloadedDictionary["location"] as? String
            self.profileUsername.text = downloadedDictionary["username"] as? String
            let url = NSURL(string: downloadedDictionary["photoURL"] as! String)
            if let data = NSData(contentsOf: url! as URL) {
                self.profilePhoto?.image = UIImage(data: data as Data)!
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
            })
        }
        photosRequiringLoading = toMaintainUnloaded
    }
}

extension ProfileViewController: LongPressDelegate {
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
                    
                    databaseRef.child("PostData").child(cell.reference).child("swipedRight").observeSingleEvent(of: .value, with:
                    { (snapshot) in
                        if snapshot.value is NSNull { } else {
                        let downloadArray = snapshot.value as! [String: NSNumber]
                        
                            for (user, _) in downloadArray {
                            
                                databaseRef.child("Users").child(user).child("savedDresses").child(cell.reference).removeValue()
                                databaseRef.child("Users").child(user).child("viewedDresses").child(cell.reference).removeValue()

                            }
                        }
                        databaseRef.child("Posts").child(cell.reference).child("numberOfImages").observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.value is NSNull { } else {
                                let numberToDelete = snapshot.value as! Int
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
                                databaseRef.child("Posts").child(cell.reference).removeValue()
                                databaseRef.child("PostData").child(cell.reference).removeValue()
                            }
                        })
                        
                        
                        databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("dressesPosted").child(cell.reference).removeValue()
                        
                        self.photosCollectionViewController.currentDresses.remove(at: (self.photosCollectionViewController.indexPath(for: cell)?.row)!)
                        
                        databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userData").child("posts").observeSingleEvent(of: .value, with: {
                            (snapshot) in
                            let numberOfListings = snapshot.value as! String
                            var numberOfListingsInt = Int(numberOfListings)!
                            numberOfListingsInt -= 1
                            databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userData").child("posts").setValue(String(numberOfListingsInt))
                            
                            self.downloadTextData()
                        })

                        self.photosCollectionViewController.reloadData()

                    })
                    
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

