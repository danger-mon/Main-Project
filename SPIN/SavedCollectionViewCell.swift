//
//  SavedCollectionViewCell.swift
//  SPIN
//
//  Created by Pelayo Martinez on 07/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit

class SavedCollectionViewCell: UICollectionViewCell {
    
    //MARK: Properties
    var jointProperties: (String?, String?, UIImage?, String?, UIImage?)
    
    @IBOutlet weak var cellImage: UIImageView!
    var ref: String = ""
    
}
