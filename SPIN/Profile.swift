//
//  Profile.swift
//  SPIN
//
//  Created by Pelayo Martinez on 11/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseAuth

class Profile {
    static var ownUsername = "pelayomartinez"
    var username = "clairezhonghtn"
    var profilePhoto = #imageLiteral(resourceName: "claire")
    var numberOfListings = 8
    var numberOfExchanges = 21
    var location = "King's College"
    var photos: [UIImage] = []
    static var ownProfile: Bool = false
    var user: FIRUser
    var reference: String
    
    init(uid: String!) {
        reference = ""
        self.reference = uid
        user = (FIRAuth.auth()?.currentUser)!
        Profile.ownUsername = (user.displayName)!
        fetchData()
    }
    
    func fetchData() {
        
        if Profile.ownProfile == true {
            username = user.displayName!
            reference = user.uid
        }
        
        let url = NSURL(string: (user.photoURL?.absoluteString)!)
        if let data = NSData(contentsOf: url! as URL) {
            profilePhoto = UIImage(data: data as Data)!
        }
        
        
        
        /*
        if Profile.ownProfile == true {
            
            username = (user.displayName)!
            let url = NSURL(string: (user.photoURL?.absoluteString)!)
            if let data = NSData(contentsOf: url as! URL) {
                profilePhoto = UIImage(data: data as Data)!
            }
            numberOfListings = 8
            numberOfExchanges = 21
            location = "Madrid"
            
        }
        else if Profile.ownProfile == false {
            
            if (username == "clairezhonghtn")
            {
                self.profilePhoto = #imageLiteral(resourceName: "claire")
                self.numberOfListings = 15
                self.numberOfExchanges = 18
                self.location = "Homerton College"
            }
            else if username == "pelayomartinez"
            {
                profilePhoto = #imageLiteral(resourceName: "profile3")
                numberOfListings = 8
                numberOfExchanges = 21
                location = "Madrid"
            }
            else if username == "aliceshinnermylove"
            {
                profilePhoto = #imageLiteral(resourceName: "profile2")
                numberOfListings = 3
                numberOfExchanges = 5
                location = "Gonville & Caius"
            }
        } */
    }
    
    
    
    func setOwnUsername(name: String!) {
        username = user.displayName!
    }
}
