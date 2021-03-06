//
//  RequestsTableViewCell.swift
//  SPIN
//
//  Created by Pelayo Martinez on 06/02/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit

class RequestsTableViewCell: UITableViewCell {

    @IBOutlet weak var dressImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var rentBuyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    var uid: String = ""
    var dressReference: String = ""
    var listingRef: String = ""
    weak var tapDelegate: RequestsTapDelegate?
    var inOrOut = ""
    var parentViewController: RequestsTableViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dressImageView.clipsToBounds = true
        dressImageView.layer.cornerRadius = 4
        dressImageView.contentMode = .scaleAspectFill
        
        messageButton.layer.borderColor = UIColor.lightGray.cgColor
        messageButton.layer.borderWidth = 1
        messageButton.layer.cornerRadius = 7
        
        moreButton.layer.borderColor = UIColor.lightGray.cgColor
        moreButton.layer.borderWidth = 1
        moreButton.layer.cornerRadius = 7
        
    }
    
    @IBAction func goToProfile(_ sender: Any) {
        print("goToProfile")
        tapDelegate?.messageNah(uid: uid, name: userLabel.text!, username: "")
    }
    
    @IBAction func more(_ sender: Any) {
        
        tapDelegate?.moreOptions(ref: listingRef, uid: uid, inOrOut: inOrOut, dressRef: dressReference)
        
    }
    
    /*
    @IBAction func goToDress(_ sender: Any) {
        print(tapDelegate.debugDescription)
        //tapDelegate?.goToDress(ref: dressReference)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "pictureViewer") as! MultipleDressScreenViewController
        
        
        nextViewController.requestTradeButton.isEnabled = false
        nextViewController.requestTradeButton.isHidden = true
        
        nextViewController.refToLoad = dressReference
        nextViewController.downloadData()
        
        self.parentViewController?.navigationController?.pushViewController(nextViewController, animated: true)

    } */
    
}

protocol RequestsTapDelegate: class {
    func messageNah(uid: String, name: String, username: String)
    func goToDress(ref: String)
    func moreOptions(ref: String, uid: String, inOrOut: String, dressRef: String)
}
