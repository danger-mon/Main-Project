//
//  DressScreenViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 09/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import Firebase

class DressScreenViewController: UIViewController {
    
    @IBOutlet weak var dressImageView: UIImageView!
    @IBOutlet weak var dressTitle: UILabel!
    @IBOutlet weak var dressDescription: UITextView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var swipedRightNumberLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    
    var shadowView: UIView!

    var jointProperties: (String?, String?, UIImage?, String?, UIImage?)
    var refToLoad: String! = ""
    var uidToLoad: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadData()
        
            self.editButton.isEnabled = false
            self.editButton.isHidden = true
        
        navigationItem.title = ""
        let image2: UIImage = #imageLiteral(resourceName: "saveIcon")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        button2.addTarget(self, action: #selector(messageScreen), for: .touchUpInside)
        let barButton2 = UIBarButtonItem(customView: button2)
        self.navigationItem.rightBarButtonItem = barButton2

        profileName.text = "Loading..."
        locationLabel.text = "Loading..."
        
        /*let tap = UITapGestureRecognizer(target: self, action: #selector(self.touch(_:)))
        profileImage.addGestureRecognizer(tap)
        profileName.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true
        profileName.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)*/
        
        shadowView = UIView(frame: profileImage.bounds)
        
        // Do any additional setup after loading the view.
        dressImageView.image = jointProperties.2
        dressImageView.contentMode = .scaleAspectFill
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.bounds.width/2
        
        /*shadowView.layer.bounds = profileImage.bounds
        shadowView.layer.cornerRadius = profileImage.bounds.width/2
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shadowOpacity = 1*/
        
        self.view.addSubview(shadowView)
        
        profileName.font = UIFont(name: "Avenir-Heavy", size: 11.0)
        locationLabel.font = UIFont(name: "Avenir", size: 9.0)
        dressTitle.font = UIFont(name: "Avenir", size: 17.0)
        dressDescription.font = UIFont(name: "Avenir", size: 11.0)


        locationLabel.textColor = UIColor(white: 0, alpha: 0.6)

        dressImageView.clipsToBounds = true
    }
    
    func messageScreen() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "conversations")
        self.present(vc!, animated: true, completion: nil)
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
            
            _ = segue.destination as! ProfileViewController
            ProfileViewController.uidToLoad = self.uidToLoad
            
        } else if segue.identifier == "editScreen" {
            
            let vc = segue.destination as! DressScreenEditViewController
            
            vc.profileNameHolder = self.profileName.text!
            vc.profileImageHolder = self.profileImage.image!
            vc.locationLabelHolder = self.locationLabel.text!
            vc.dressImageViewHolder = self.dressImageView.image!
            vc.titleFieldHolder = self.dressTitle.text!
            vc.dressDescriptionHolder = self.dressDescription.text!
            vc.ref = self.refToLoad
        } else if segue.identifier == "tradeWarning" {
            let vc = segue.destination as! StartTradeViewController
            
            vc.dressReference = self.refToLoad
            vc.ownerReference = self.uidToLoad
            vc.ownerName = self.profileName.text!
            vc.dressTitle = self.dressTitle.text!
        }
    }
    func downloadData() {
        //let currentUser = (FIRAuth.auth()?.currentUser?.uid)!
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Posts").child(refToLoad).observeSingleEvent(of: .value, with: {
            (snapshot) in
            let downloadedDictionary = snapshot.value as! [String: AnyObject]
            
            self.dressTitle.text = downloadedDictionary["title"] as? String
            self.dressDescription.text = downloadedDictionary["description"] as! String
            self.profileName.text = downloadedDictionary["username"] as? String
            self.uidToLoad = downloadedDictionary["uid"] as! String
           
            databaseRef.child("Users").child(self.uidToLoad).child("userData").observeSingleEvent(of: .value, with: {
                snapshot in
                let downloadDict = snapshot.value as! NSDictionary
                self.locationLabel.text = downloadDict["location"] as? String
                
                let url = NSURL(string: (downloadDict["photoURL"] as! String))
                if let data = NSData(contentsOf: url! as URL) {
                    self.profileImage.image = UIImage(data: data as Data)!
                }
                if (self.uidToLoad == FIRAuth.auth()?.currentUser?.uid) {
                    self.editButton.isEnabled = true
                    self.editButton.isHidden = false
                }
            })
            
        })
        
        databaseRef.child("PostData").child(refToLoad).child("swipedRight").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                self.swipedRightNumberLabel.text = "0"
            } else {
                let dict = snapshot.value as! [String: AnyObject]
                self.swipedRightNumberLabel.text = String(dict.count)
            }
        })
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    */

}
