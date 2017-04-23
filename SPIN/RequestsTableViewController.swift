//
//  RequestsTableViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 06/02/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import Firebase

class RequestsTableViewController: UITableViewController, RequestsTapDelegate {
    
    struct request {
        var image: UIImage
        var title: String
        var user: String
        var rentBuy: String
        var price: String
        var reference: String
        var uid: String
    }
    
    var incomingRequests: [request] = []
    var outgoingRequests: [request] = []
    var allRequests: [[request]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image2: UIImage = #imageLiteral(resourceName: "envelope")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        button2.addTarget(self, action: #selector(messageScreen), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: button2)
        barButton2.addBadge(text: "\(BadgeHandler.messageBadgeNumber)")
        self.navigationItem.rightBarButtonItem = barButton2

        self.navigationController?.navigationBar.isTranslucent = false
        self.tableView.separatorColor = UIColor.white
        
        catchIncomingRequests()
        catchOutgoingRequests()

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
    }

    func catchIncomingRequests() {
        let databaseRef = FIRDatabase.database().reference()
        let storageRef = FIRStorage.storage().reference()

        databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("incomingRequests").observe(.childAdded, with: { (snapshot) in
            if snapshot.value is NSNull { } else {
                let downloadDict = snapshot.value as! [String: Any]
                
                var newRequest = request(image: #imageLiteral(resourceName: "loading"), title: downloadDict["dressTitle"] as! String, user: downloadDict["requesterName"] as! String, rentBuy: downloadDict["rentBuy"] as! String, price: downloadDict["price"] as! String, reference: downloadDict["dressReference"] as! String, uid: downloadDict["requestUid"] as! String)
                
                storageRef.child("dressImages").child("\(downloadDict["dressReference"] as! String)/1.jpg").data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print(error as Any)
                    } else {
                        newRequest.image = UIImage(data: data!)!
                        self.incomingRequests.append(newRequest)
                        self.getSectionsFromData()
                    }
                })

            }
        })
    }
    
    func catchOutgoingRequests() {
        print("Outgoing")
        let databaseRef = FIRDatabase.database().reference()
        let storageRef = FIRStorage.storage().reference()
        databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("outgoingRequests").observe(.childAdded, with: { (snapshot) in
            
            if snapshot.value is NSNull { } else {
                let downloadDict = snapshot.value as! [String: Any]
                
                var newRequest = request(image: #imageLiteral(resourceName: "loading"), title: downloadDict["dressTitle"] as! String, user: downloadDict["ownerName"] as! String, rentBuy: downloadDict["rentBuy"] as! String, price: downloadDict["price"] as! String, reference: downloadDict["dressReference"] as! String, uid: downloadDict["ownerUid"] as! String)
                
                storageRef.child("dressImages").child("\(downloadDict["dressReference"] as! String)/1.jpg").data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print(error as Any)
                    } else {
                        newRequest.image = UIImage(data: data!)!
                        self.outgoingRequests.append(newRequest)
                        self.getSectionsFromData()
                    }
                })
            }
        })

    }
    
    func getSectionsFromData() {
        allRequests = [incomingRequests, outgoingRequests]
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return incomingRequests.count + outgoingRequests.count + 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String = ""
        if section == 0 {
            title = "Incoming Requests"
        } else if section == incomingRequests.count + 1 {
            title = "Outgoing Requests"
        } else {
            title = "  "
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == incomingRequests.count {
            return 10
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if section == 0 || section == incomingRequests.count + 1 {
            return 0
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == incomingRequests.count + 1 {
            return 22
        } else {
            return 10
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        if section == 0 || section == incomingRequests.count + 1 {
            header.textLabel?.textColor = UIColor.black
            header.textLabel?.font = UIFont(name: "Avenir-Medium", size: 16)
            header.textLabel?.frame = header.frame
            header.backgroundView?.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
            
        } else {
            header.backgroundColor = UIColor.white
            header.backgroundView?.backgroundColor = UIColor.white
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footer = view as? UITableViewHeaderFooterView else { return }
        footer.backgroundView?.backgroundColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "request") as! RequestsTableViewCell
        print(indexPath.section)
        if indexPath.section != 0 && indexPath.section != incomingRequests.count + 1 {
            
            if indexPath.section <= incomingRequests.count {
                print("Yeah \(indexPath.section)")
                cell.titleLabel.text = allRequests[0][indexPath.section - 1].title
                cell.userLabel.text = allRequests[0][indexPath.section - 1].user
                cell.rentBuyLabel.text = allRequests[0][indexPath.section - 1].rentBuy
                cell.priceLabel.text = allRequests[0][indexPath.section - 1].price
                cell.dressImageView.image = allRequests[0][indexPath.section - 1].image
                cell.uid = allRequests[0][indexPath.section - 1].uid
                cell.dressReference = allRequests[0][indexPath.section - 1].reference
                cell.isUserInteractionEnabled = true
                cell.tapDelegate = self
            } else {
                let index = indexPath.section - incomingRequests.count - 2
                cell.titleLabel.text = allRequests[1][index].title
                cell.userLabel.text = allRequests[1][index].user
                cell.rentBuyLabel.text = allRequests[1][index].rentBuy
                cell.priceLabel.text = allRequests[1][index].price
                cell.dressImageView.image = allRequests[1][index].image
                cell.uid = allRequests[1][index].uid
                cell.dressReference = allRequests[1][index].reference
                cell.isUserInteractionEnabled = true
                cell.tapDelegate = self
            }
            
            cell.titleLabel.alpha = 0
            cell.userLabel.alpha = 0
            cell.priceLabel.alpha = 0
            cell.rentBuyLabel.alpha = 0
            cell.dressImageView.alpha = 0
            cell.messageButton.center.x += 200
            /*cell.layer.shadowColor = UIColor.darkGray.cgColor
            cell.layer.shadowRadius = 10
            cell.layer.shadowOpacity = 1
            cell.layer.shadowOffset = CGSize(width: 0, height: 0) */
            cell.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
            cell.layer.borderWidth = 1
            //cell.layer.cornerRadius = 7
            cell.clipsToBounds = false
            self.tableView.bringSubview(toFront: cell)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            (cell as! RequestsTableViewCell).titleLabel.alpha = 1
            (cell as! RequestsTableViewCell).userLabel.alpha = 1
            (cell as! RequestsTableViewCell).priceLabel.alpha = 1
            (cell as! RequestsTableViewCell).rentBuyLabel.alpha = 1
            (cell as! RequestsTableViewCell).dressImageView.alpha = 1
            (cell as! RequestsTableViewCell).messageButton.center.x -= 200
        }, completion: nil)

    }
    
    func goToDress(ref: String) {
        
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "pictureViewer") as! MultipleDressScreenViewController
        
        print(nextViewController.view.description)
        nextViewController.requestTradeButton.isEnabled = false
        nextViewController.requestTradeButton.isHidden = true
        
        nextViewController.refToLoad = ref
        nextViewController.downloadData()
        
        self.navigationController?.pushViewController(nextViewController, animated: true) */
 
    }
    
    @IBAction func tapOnRequest(_ sender: Any) {
        let tapped = sender as! UITapGestureRecognizer
        let tappedView = tapped.view as! RequestsTableViewCell
        let ref = tappedView.dressReference
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "pictureViewer") as! MultipleDressScreenViewController
        
        print(nextViewController.view.description)
        nextViewController.requestTradeButton.isEnabled = false
        nextViewController.requestTradeButton.isHidden = true
        
        nextViewController.refToLoad = ref
        nextViewController.downloadData()
        
        self.navigationController?.pushViewController(nextViewController, animated: true)

        
    }
    
    func message(uid: String, name: String, username: String) {
        
        let theReference = FIRDatabase.database().reference()
        var alreadyThere = false
        //(sender as! UIButton).isEnabled = false
        
        theReference.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("conversations").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var conversationReference = ""
            
            let enumerator = snapshot.children
            
            while let nextChild = enumerator.nextObject() as? FIRDataSnapshot {
                
                let download = nextChild.value as! [String: Any]
                
                if download["uid"] as? String == uid {
                    alreadyThere = true
                    conversationReference = nextChild.key
                } else { alreadyThere = false }
            }
            
            if alreadyThere == true {
                
                let destinationNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "conversations") as! ChatNavigationController
                
                let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "chat") as! ChatViewController
                
                
                destinationViewController.senderDisplayName = name
                destinationViewController.senderId = (FIRAuth.auth()?.currentUser?.uid)!
                destinationViewController.refToLoad = conversationReference
                //TODO: Add URL image download
                destinationViewController.name = name //self.profileUsername.text!
                
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
                            "uid": uid,
                            "name": name,
                            "timestamp": Int32(NSDate.timeIntervalSinceReferenceDate)] as [String : Any]
                
                var postOther = postOwn
                postOther["name"] = Profile.ownUsername
                postOther["uid"] = (FIRAuth.auth()?.currentUser?.uid)!
                
                let fanoutObject = ["/Users/\((FIRAuth.auth()?.currentUser?.uid)!)/conversations/\(id.key)": postOwn,
                                    "/Users/\(uid)/conversations/\(id.key)": postOther,
                                    "/Conversations/\(id.key)/timestamp": Int32(NSDate.timeIntervalSinceReferenceDate),
                                    "/Users/\((FIRAuth.auth()?.currentUser?.uid)!)/conversations/\(id.key)/unseen": 0,
                                    "/Users/\(ProfileViewController.uidToLoad)/conversations/\(id.key)/unseen": 0] as [String : Any]
                
                FIRDatabase.database().reference().updateChildValues(fanoutObject)
                
                let destinationNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "conversations") as! ChatNavigationController
                
                let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "chat") as! ChatViewController
                
                destinationViewController.senderDisplayName = Profile.ownUsername
                destinationViewController.senderId = (FIRAuth.auth()?.currentUser?.uid)!
                destinationViewController.refToLoad = id.key
                destinationViewController.name = name
                destinationNavigationController.pushViewController( destinationViewController, animated: true)
                
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                self.view.window!.layer.add(transition, forKey: kCATransition)
                
                self.present(destinationNavigationController, animated: true, completion: nil)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToProfile") {
            
            print(sender.debugDescription)
            
            _ = segue.destination as! ProfileViewController
        }
    }
}
