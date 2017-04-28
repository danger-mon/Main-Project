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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func goToProfile(_ sender: Any) {
        tapDelegate?.message(uid: uid, name: userLabel.text!, username: "")
    }
    
    @IBAction func more(_ sender: Any) {
        
        tapDelegate?.moreOptions(ref: listingRef, uid: uid, inOrOut: inOrOut, dressRef: dressReference)
        
    }
    
    @IBAction func goToDress(_ sender: Any) {
        print(tapDelegate.debugDescription)
        tapDelegate?.goToDress(ref: dressReference)
    }
    
}

protocol RequestsTapDelegate: class {
    func message(uid: String, name: String, username: String)
    func goToDress(ref: String)
    func moreOptions(ref: String, uid: String, inOrOut: String, dressRef: String)
}
