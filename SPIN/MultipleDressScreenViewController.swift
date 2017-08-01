import UIKit
import Firebase

class MultipleDressScreenViewController: UIViewController {
    
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dressImagesCollectionView: MultipleDressCollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var dressTitle: UILabel!
    @IBOutlet weak var dressDescription: UITextView!
    @IBOutlet weak var swipedRightNumberLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var requestTradeButton: UIButton!
    @IBOutlet weak var swipedRightImage: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var rentSellLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    

    @IBOutlet var profileGoTo: UITapGestureRecognizer!
    
    var refToLoad: String! = ""
    var uidToLoad: String! = ""
    var dontDownload = false
    var timestamp: Double = 0
    
    override func viewWillAppear(_ animated: Bool) {
        //profileName.alpha = 0
        //locationLabel.alpha = 0
        //profileImage.alpha = 0
        super.viewWillAppear(animated)
        /*if editButton != nil {
            editButton.alpha = 0
        } */
        
        if editButton != nil {
            editButton.layer.cornerRadius = 7
            editButton.layer.borderColor = UIColor.darkGray.cgColor
            editButton.layer.borderWidth = 1
            if requestTradeButton != nil {
                requestTradeButton.isEnabled = false
                requestTradeButton.isHidden = true
            }
        }
        
        if moreButton != nil {
            moreButton.isHidden = true
            moreButton.isEnabled = false
        }
        
        if profileGoTo != nil {
            profileGoTo.isEnabled = false
        }
        
        if requestTradeButton != nil {
            requestTradeButton.isEnabled = false
            requestTradeButton.isHidden = true
        }
        
        dressTitle.alpha = 0
        dressDescription.alpha = 0
        swipedRightNumberLabel.alpha = 0
        dressImagesCollectionView.alpha = 0
        if BadgeHandler.messageBadgeNumber != 0 {
            self.navigationItem.rightBarButtonItem?.setBadge(text: "\(BadgeHandler.messageBadgeNumber)")
        } else {
            self.navigationItem.rightBarButtonItem?.setBadge(text: "")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileName.text = "Loading..."
        navigationItem.title = ""
        let image2: UIImage = #imageLiteral(resourceName: "envelope")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        button2.addTarget(self, action: #selector(messageScreen), for: .touchUpInside)
        let barButton2 = UIBarButtonItem(customView: button2)
        self.navigationItem.rightBarButtonItem = barButton2
        
        if requestTradeButton != nil {
            requestTradeButton.layer.borderWidth = 1
            requestTradeButton.layer.borderColor = UIColor.lightGray.cgColor
            requestTradeButton.layer.cornerRadius = 7
        }
        
        profileName.text = "Loading..."
        locationLabel.text = "Loading..."
        
        if self.editButton != nil {
            self.editButton.isEnabled = false
            self.editButton.isHidden = true
        }
        
        self.navigationController?.navigationBar.topItem?.title = " "
        
        /*let tap = UITapGestureRecognizer(target: self, action: #selector(self.touch(_:)))
         profileImage.addGestureRecognizer(tap)
         profileName.addGestureRecognizer(tap)
         profileImage.isUserInteractionEnabled = true
         profileName.isUserInteractionEnabled = true
         view.addGestureRecognizer(tap)*/
        
        //shadowView = UIView(frame: profileImage.bounds)
        
        // Do any additional setup after loading the view.
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.bounds.width/2
        
        /*shadowView.layer.bounds = profileImage.bounds
         shadowView.layer.cornerRadius = profileImage.bounds.width/2
         shadowView.layer.shadowColor = UIColor.gray.cgColor
         shadowView.layer.shadowRadius = 4
         shadowView.layer.shadowOpacity = 1*/
        
        //self.view.addSubview(shadowView)
        
        profileName.font = UIFont(name: "Avenir-Heavy", size: 11.0)
        locationLabel.font = UIFont(name: "Avenir", size: 9.0)
        dressTitle.font = UIFont(name: "Avenir", size: 17.0)
        dressDescription.font = UIFont(name: "Avenir", size: 11.0)
        dressImagesCollectionView.currentPictures = []
        //dressImagesCollectionView.reloadData()
        
        
        locationLabel.textColor = UIColor(white: 0, alpha: 0.6)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !dontDownload {
            downloadData()
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
    
    func touch(_ sender: UITapGestureRecognizer)
    {
        // navigate to another
        //self.performSegue(withIdentifier: "loadProfile", sender: self)
        let viewToPresent = ProfileViewController()
        present(viewToPresent, animated: true, completion: {
            viewToPresent.profileToLoad = self.profileName.text
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goToProfile") {
            
            let svc = segue.destination as! ProfileViewController
            svc.noSettings = true
            svc.isHeroEnabled = false
            
            /*
            svc.isHeroEnabled = true
            self.isHeroEnabled = true
            self.navigationController?.isHeroEnabled = true
            svc.profilePhoto?.heroID = "profilePhoto"
            self.profileImage.heroID = "profilePhoto"
            svc.profileUsername.heroID = "profileLabel"
            self.profileName.heroID = "profileLabel"
            svc.locationLabel.heroID = "location"
            self.locationLabel.heroID = "location"
            */
 
            ProfileViewController.uidToLoad = self.uidToLoad
            
        } else if segue.identifier == "editScreen" {
            let vc = segue.destination as! UploadViewController
            
            _ = vc.view.description
            var pictures = dressImagesCollectionView.currentPictures
            
            for _ in 0..<(4 - self.dressImagesCollectionView.currentPictures.count) {
                pictures.append(#imageLiteral(resourceName: "placeholderImage"))
            }
            
            vc.uploadCollectionView.currentPictures = pictures
            print(self.timestamp)
            vc.timestamp = self.timestamp
            print(vc.timestamp)
            vc.dressNameField.text = self.dressTitle.text!
            vc.dressDescriptionField.text = self.dressDescription.text!
            var string = self.priceLabel.text
            string?.remove(at: (string?.startIndex)!)
            vc.priceField.text = string
            
            if self.rentSellLabel.text == "rent:" {
                vc.rentSellSegmentedControl.selectedSegmentIndex = 0
            } else if rentSellLabel.text == "sell:" {
                vc.rentSellSegmentedControl.selectedSegmentIndex = 1
            }
            vc.refToLoad = self.refToLoad
            
        } else if segue.identifier == "tradeWarning" {
            let vc = segue.destination as! StartTradeViewController
            
            vc.dressReference = self.refToLoad
            vc.ownerReference = self.uidToLoad
            vc.ownerName = self.profileName.text!
            vc.dressTitle = self.dressTitle.text!
            vc.rentBuy = self.rentSellLabel.text!
            vc.price = self.priceLabel.text!
        }
    }
    func downloadData() {
        //let currentUser = (FIRAuth.auth()?.currentUser?.uid)!
        var numberOfImages = 0
        
        let databaseRef = FIRDatabase.database().reference()
        
        databaseRef.child("Posts").child(refToLoad).observeSingleEvent(of: .value, with: {
            (snapshot) in
            if snapshot.value is NSNull { } else {
                let downloadedDictionary = snapshot.value as! [String: AnyObject]
                
                // Set text variables
                    self.dressTitle.text = downloadedDictionary["title"] as? String
                    self.dressDescription.text = downloadedDictionary["description"] as! String
                    self.profileName.text = downloadedDictionary["username"] as? String
                self.rentSellLabel.text = "\(downloadedDictionary["rentSell"] as! String):"
                self.priceLabel.text = "£\(downloadedDictionary["price"] as! String)"
                
                UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                    self.dressTitle.alpha = 1
                    self.dressDescription.alpha = 1
                    self.profileName.alpha = 1
                }, completion: nil)
                
                
                
                self.uidToLoad = downloadedDictionary["uid"] as! String
                numberOfImages = Int(downloadedDictionary["numberOfImages"] as! NSNumber)
                self.timestamp = downloadedDictionary["timestamp"] as! Double
                self.dressImagesCollectionView.currentPictures = []
                for _ in 0..<numberOfImages {
                    self.dressImagesCollectionView.currentPictures.append(#imageLiteral(resourceName: "loading"))
                }
                
                if self.profileGoTo != nil {
                    self.profileGoTo.isEnabled = true
                }
                if self.requestTradeButton != nil {
                    self.requestTradeButton.isEnabled = true
                }
                
                for i in 0..<numberOfImages {
                    let actual = i
                    let pathReference = FIRStorage.storage().reference(withPath: "dressImages/\(self.refToLoad!)/\(i + 1).jpg")
                    pathReference.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if data != nil {
                            self.dressImagesCollectionView.currentPictures[i] = (UIImage(data: data!)!)
                            self.dressImagesCollectionView.reloadData()
                            if actual == 0 {
                                UIView.animate(withDuration: 0.3, animations: {
                                    self.dressImagesCollectionView.alpha = 1
                                })
                            }
                        }
                        print("i \(i), number: \(numberOfImages - 1)")
                        if i == numberOfImages - 1 {
                            print("hey")
                            if self.editButton != nil {
                                print("enabling")
                                if (FIRAuth.auth()?.currentUser?.uid)! == self.uidToLoad {
                                    if self.editButton != nil {
                                        self.editButton.isEnabled = true
                                        self.editButton.isHidden = false
                                    }
                                } else {
                                    print("yp")
                                    if self.requestTradeButton != nil {
                                        print("ho")
                                        self.requestTradeButton.isEnabled = true
                                        self.requestTradeButton.isHidden = false
                                    }
                                    if self.moreButton != nil {
                                        self.moreButton.isEnabled = true
                                        self.moreButton.isHidden = false
                                    }
                                }
                            } else {
                                
                                if self.requestTradeButton != nil {
                                    self.requestTradeButton.isEnabled = true
                                    self.requestTradeButton.isHidden = false
                                }
                                if self.moreButton != nil {
                                    self.moreButton.isEnabled = true
                                    self.moreButton.isHidden = false
                                }
                            }

                        }
                    })
                }

                databaseRef.child("Users").child(self.uidToLoad).child("userData").observeSingleEvent(of: .value, with: {
                    snapshot in
                    
                    let downloadDict = snapshot.value as! NSDictionary
                    self.locationLabel.text = downloadDict["location"] as? String
                    
                    let url = NSURL(string: (downloadDict["photoURL"] as! String))
                    if let data = NSData(contentsOf: url! as URL) {
                        self.profileImage.image = UIImage(data: data as Data)!
                    }
                })
            }
        })
        
        databaseRef.child("PostData").child(refToLoad).child("swipedRight").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                self.swipedRightNumberLabel.text = "0"
                
            } else {
                
                let dict = snapshot.value as! [String: AnyObject]
                self.swipedRightNumberLabel.text = String(dict.count)
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                    self.swipedRightNumberLabel.alpha = 1
                }, completion: nil)            }
        })
    }
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "More", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { action in
            
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("sendReport")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextViewController = storyboard.instantiateViewController(withIdentifier: "report") as! ReportViewController
                nextViewController.dressRef = self.refToLoad
                nextViewController.ownerUid = self.uidToLoad
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
            switch action.style{
            case .cancel:
                print("cancel")
            default: break
                
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
