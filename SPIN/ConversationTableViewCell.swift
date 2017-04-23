//
//  ConversationTableViewCell.swift
//  SPIN
//
//  Created by Pelayo Martinez on 19/12/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var recipientImageView: UIImageView!
    var ref: String = ""
    var photoURL: String = ""
    var uid: String = ""
    @IBOutlet weak var unseenLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        recipientImageView.clipsToBounds = true
        recipientImageView.contentMode = .scaleAspectFill
        unseenLabel.layer.cornerRadius = 11
        unseenLabel.clipsToBounds = true
        unseenLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
