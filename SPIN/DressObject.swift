//
//  DataLoader.swift
//  SPIN
//
//  Created by Pelayo Martinez on 04/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class DressObject: NSObject, NSCoding {
    
    //MARK: Properties
    var name: String! = ""
    var dressDescription: String! = ""
    var image: UIImage! = #imageLiteral(resourceName: "placeholderImage")
    var profile: String! = ""
    var profilePhoto: UIImage! = #imageLiteral(resourceName: "placeholderImage")
    var key: String = ""
    var location: String? = ""
    var url: NSURL = NSURL(string: "")!
    
    //let ref: FIRDatabaseReference?
    let ref: String!
    var timestamp: Double = 0
    
    struct PropertyKey {
        static let nameKey = "name"
        static let dressDescriptionKey = "description"
        static let imageKey = "image"
        static let profileKey = "profile"
        static let profilePhotoKey = "photo"
    }
    
    //MARK: Saving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("savedDresses")
    
    init(name: String, dressDescription: String, image: UIImage?, profile: String, profilePhoto: UIImage) {
        self.name = name
        self.dressDescription = dressDescription
        self.image = image
        self.profile = profile
        self.profilePhoto = profilePhoto
        key = "n/a"
        ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = (snapshot.value as! NSDictionary).allKeys.first as! String
        let snapshotValue = (snapshot.value as! NSDictionary).allValues.first as! NSDictionary
        
        //let snapshotValue = snapshotVal[0] as! NSDictionary
        //name = snapshotValue["title"] as! String
        name = key
        dressDescription = snapshotValue["description"] as! String
        image = #imageLiteral(resourceName: "claire")
        profile = snapshotValue["username"] as! String
        timestamp = snapshotValue["timestamp"] as! Double
        if snapshotValue["location"] != nil {
            location = snapshotValue["location"] as? String
        } else { location = "" }
        
        //TODO: Get profile Photo
        if snapshotValue["profilePhotoURL"] != nil {
            
            url = NSURL(string: (snapshotValue["profilePhotoURL"] as! String))!
            if let data = NSData(contentsOf: url as URL) {
                profilePhoto = UIImage(data: data as Data)!
            }
        }
        
        ref = key //snapshot.key
        //ref = snapshot.ref

    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(dressDescription, forKey: PropertyKey.dressDescriptionKey)
        aCoder.encode(image, forKey: PropertyKey.imageKey)
        aCoder.encode(profilePhoto, forKey: PropertyKey.profilePhotoKey)
        aCoder.encode(profile, forKey: PropertyKey.profileKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        let dressDescription = aDecoder.decodeObject(forKey: PropertyKey.dressDescriptionKey) as! String
        let image = aDecoder.decodeObject(forKey: PropertyKey.imageKey) as! UIImage
        let profilePhoto = aDecoder.decodeObject(forKey: PropertyKey.profilePhotoKey) as! UIImage
        let profile = aDecoder.decodeObject(forKey: PropertyKey.profileKey) as! String
        
        self.init(name: name, dressDescription: dressDescription, image: image, profile: profile, profilePhoto: profilePhoto)
    }
}
