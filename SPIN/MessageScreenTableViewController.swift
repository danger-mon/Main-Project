//
//  MessageScreenViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 19/12/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import OneSignal

class MessageScreenTableViewController: UITableViewController {

    private lazy var databaseRef: FIRDatabaseReference = FIRDatabase.database().reference()
    private var channelRefHandle: FIRDatabaseHandle?
    struct conversation {
        var id: String
        var timestamp: NSNumber
        var name: String
        var url: String
        var uid: String
        var unseen: Int
    }
    var conversations: [conversation] = []
    var ownUsername: String = ""
    var logoView: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeChannels()
        
        let logo = #imageLiteral(resourceName: "logoone")
        logoView = UIImageView(image: logo)
        logoView.frame = CGRect(x: (Int(UIScreen.main.bounds.width/2) - 35), y: Int(0.75 * ((self.navigationController?.navigationBar.bounds.height)! - 35)), width: 70, height: 35)
        logoView.contentMode = .scaleAspectFit
        self.navigationController?.navigationBar.addSubview(logoView)

                
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( #imageLiteral(resourceName: "left-arrow"), for: .normal)
        button2.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: button2)
        self.navigationItem.leftBarButtonItem = barButton2
        
               
        
        databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userData").observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as! [String: String]
            
            self.ownUsername = dict["username"]!
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.logoView.alpha = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.logoView.alpha = 0
        }
    }
    
        
    func goBack() {
        
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConversationTableViewCell
        
        cell.name.text = conversations[indexPath.row].name
        
        databaseRef.child("Users").child(conversations[indexPath.row].uid).child("userData").child("photoURL").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil
            {
                if let url = NSURL(string: snapshot.value as! String)
                {
                    if let data = NSData(contentsOf: url as URL) {
                        cell.recipientImageView.image = UIImage(data: data as Data)!
                    }
                }
            }
        })
        cell.recipientImageView.clipsToBounds = true
        cell.recipientImageView.layer.cornerRadius = cell.recipientImageView.frame.height / 2
        cell.ref = conversations[indexPath.row].id
        cell.photoURL = conversations[indexPath.row].url
        cell.uid = conversations[indexPath.row].uid
        cell.selectionStyle = .none
        if conversations[indexPath.row].unseen != 0 {
            cell.unseenLabel.text = String(conversations[indexPath.row].unseen)
            cell.unseenLabel.isHidden = false
        }
        
        return cell
    }
    
    func observeChannels() {
        
        databaseRef.child("Users").child( (FIRAuth.auth()?.currentUser?.uid)! ).child("conversations").observe(.childAdded, with: { (snapshot) in
            
            var downloadedDict = snapshot.value as! [String: AnyObject]
            var photoURL: String = ""
            if downloadedDict["photoURL"] == nil {
                photoURL = "http://www.socialmediasearch.co.uk/wp-content/uploads/2014/12/s5.jpg"
            } else {
                photoURL = downloadedDict["photoURL"] as! String
            }
            
            
            let keyExists = (downloadedDict["blocked"] != nil)
            
            print(keyExists)
            
            if keyExists {
                if downloadedDict["blocked"] as! String == "false" {
                    self.conversations.append(conversation(id: downloadedDict["id"] as! String, timestamp: downloadedDict["timestamp"] as! NSNumber, name: downloadedDict["name"] as! String, url: photoURL, uid: downloadedDict["uid"] as! String, unseen: downloadedDict["unseen"] as! Int))
                    self.tableView.reloadData()
                }
            } else {
                self.conversations.append(conversation(id: downloadedDict["id"] as! String, timestamp: downloadedDict["timestamp"] as! NSNumber, name: downloadedDict["name"] as! String, url: photoURL, uid: downloadedDict["uid"] as! String, unseen: downloadedDict["unseen"] as! Int))
                self.tableView.reloadData()

            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loadConversation") {
            
            let svc = segue.destination as! ChatViewController
            let cellSender = sender as! ConversationTableViewCell
            
            svc.senderDisplayName = ownUsername
            svc.senderId = (FIRAuth.auth()?.currentUser?.uid)!
            svc.refToLoad = cellSender.ref
            svc.photoURL = cellSender.photoURL
            svc.name = cellSender.name.text!
            svc.uid = cellSender.uid
            cellSender.unseenLabel.text = "0"
            cellSender.unseenLabel.isHidden = true
        }
    }
}
