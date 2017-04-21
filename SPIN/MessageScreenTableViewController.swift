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
    }
    var conversations: [conversation] = []
    var ownUsername: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeChannels()
        var logoView: UIImageView = UIImageView()
        let logo = UIImage(named: "SPIN")
        logoView = UIImageView(image: logo)
        logoView.frame = CGRect(x: (Int(UIScreen.main.bounds.width/2) - 50), y: 0, width: 100, height: 50)
        logoView.contentMode = .scaleAspectFit
        navigationItem.titleView = logoView
        
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
    
    func goBack() {
        
        let transition = CATransition()
        transition.duration = 0.3
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
            let url = NSURL(string: snapshot.value as! String)
            if let data = NSData(contentsOf: url! as URL) {
                cell.recipientImageView.image = UIImage(data: data as Data)!
            }
        })
        cell.recipientImageView.clipsToBounds = true
        cell.recipientImageView.layer.cornerRadius = cell.recipientImageView.frame.height / 2
        cell.ref = conversations[indexPath.row].id
        cell.photoURL = conversations[indexPath.row].url
        cell.uid = conversations[indexPath.row].uid
        
        return cell
    }
    
    func observeChannels() {
        
        databaseRef.child("Users").child( (FIRAuth.auth()?.currentUser?.uid)! ).child("conversations").observe(.childAdded, with: { (snapshot) in
            
            let downloadedDict = snapshot.value as! [String: AnyObject]
            self.conversations.append(conversation(id: downloadedDict["id"] as! String, timestamp: downloadedDict["timestamp"] as! NSNumber, name: downloadedDict["name"] as! String, url: downloadedDict["photoURL"] as! String, uid: downloadedDict["uid"] as! String))
            self.tableView.reloadData()
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
        }
    }
}
