//
//  MiniProfile.swift
//  SPIN
//
//  Created by Pelayo Martinez on 03/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit

class MiniProfile: UIView {

    var profileCircle: UIImageView!
    var profileCircleImage: UIImage!
    var profileName: UILabel!
    var location: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        //profileCircleImage = UIImage(named: "claire")
        profileCircleImage = UIImage()
        profileCircle = UIImageView(image: profileCircleImage)
        //profileCircle.frame = CGRect(x: 25, y: 80, width: 35, height: 35)
        profileCircle.frame = CGRect(x: 2, y: 0, width: 35, height: 35)
        profileCircle.contentMode = .scaleAspectFill
        
        profileCircle.layer.cornerRadius = 17.5
        profileCircle.layer.shadowRadius = 4;
        profileCircle.layer.shadowOpacity = 0.5;
        profileCircle.layer.shadowOffset = CGSize(width: 4, height: 4);
        
        profileCircle.clipsToBounds = true
        self.addSubview(profileCircle)
        
        profileName = UILabel()
        profileName.text = ""
        profileName.font = UIFont(name: "Avenir-Heavy", size: 11.0)
        profileName.frame = CGRect(x: 47, y: 3, width: 300, height: 18)
        profileName.textColor = UIColor(white: 0, alpha: 0.8)
        self.addSubview(profileName)
        
        location = UILabel()
        location.text = ""
        location.font = UIFont(name: "Avenir", size: 9.0)
        location.frame = CGRect(x: 47, y: 15, width: 300, height: 18)
        location.textColor = UIColor(white: 0, alpha: 0.6)
        self.addSubview(location)
    }
    
    func updateProfileView(image: UIImage, profileName: String) {
        
        UIView.transition(with: profileCircle, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.profileCircle.image = image
        }, completion: nil)
        UIView.transition(with: self.profileName, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.profileName.text = profileName
        }, completion: nil)
        
    }

}
