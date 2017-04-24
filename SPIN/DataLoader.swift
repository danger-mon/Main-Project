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

class DataLoader {
    
    var dressInProgress: DressObject! = DressObject(name: "", dressDescription: "", image: #imageLiteral(resourceName: "claire"), profile: "", profilePhoto: #imageLiteral(resourceName: "claire"))
    var reelDressArray: [DressObject] = []
    var names: [String]!
    var descriptions: [String]!
    var images: [UIImage]!
    var profile: [String]!
    var profilePhotos: [UIImage]!
    var photoDictionary: [String: UIImage]!

    init() {
        
        names = ["BCBG Sequined Two Body", "Open Back Size 6 Blue Dress", "Long size 5 dress", "BCBG Sequined Two Body", "Open Back Size 6 Blue Dress", "Long size 5 dress", "BCBG Sequined Two Body", "Open Back Size 6 Blue Dress", "Translucent open leg size 5 dress"]
        descriptions = ["UK Size 6 \nRent or Borrow\nKing's College","UK Size 8 \nRent or Borrow\nHomerton College", "UK Size 4 \nRent or Borrow\nAnglia Ruskin","UK Size 6 \nRent or Borrow\nKing's College","UK Size 8 \nRent or Borrow\nHomerton College", "UK Size 4 \nRent or Borrow\nAnglia Ruskin", "UK Size 6 \nRent or Borrow\nKing's College","UK Size 8 \nRent or Borrow\nHomerton College", "UK Size 4 \nRent or Borrow\nAnglia Ruskin"]
        images = [#imageLiteral(resourceName: "dress"),#imageLiteral(resourceName: "dress7"),#imageLiteral(resourceName: "dress8"), #imageLiteral(resourceName: "dress9"),#imageLiteral(resourceName: "dress3"),#imageLiteral(resourceName: "dress4"),#imageLiteral(resourceName: "dress5"),#imageLiteral(resourceName: "dress6"),#imageLiteral(resourceName: "dress 4")]
        profile = ["clairezhonghtn", "aliceshinnermylove","pelayomartinez","clairezhonghtn", "aliceshinnermylove","pelayomartinez", "clairezhonghtn", "aliceshinnermylove","pelayomartinez"]
        profilePhotos = [#imageLiteral(resourceName: "claire"),#imageLiteral(resourceName: "profile2"),#imageLiteral(resourceName: "profile3"),#imageLiteral(resourceName: "claire"),#imageLiteral(resourceName: "profile2"),#imageLiteral(resourceName: "profile3"),#imageLiteral(resourceName: "claire"),#imageLiteral(resourceName: "profile2"),#imageLiteral(resourceName: "profile3")]
        for i in 0..<2 {
            dressInProgress = DressObject(name: names[i], dressDescription: descriptions[i], image: images[i], profile: profile[i], profilePhoto: profilePhotos[i])
            reelDressArray.append(dressInProgress)
        }
        //loadData()
    }
    
    
    /*func loadData() {
        
        catchDressesFromServer(seenDresses: [""])
    }*/
    
    func getDressReel() -> [DressObject] {
        
        return reelDressArray
    }
    
    func catchDressesFromServer(seenDresses: [String]) {

        dressInProgress = DressObject(name: "", dressDescription: "", image: #imageLiteral(resourceName: "claire"), profile: "", profilePhoto: #imageLiteral(resourceName: "claire"))
        let databaseRef = FIRDatabase.database().reference()
        
        //Download database stuff
        databaseRef.child("Posts").observeSingleEvent(of: .value, with: {
            snapshot in
            
            for item in snapshot.children {
                
                //Get the dress title, description, profileName, price, buy/sell
                let newDress = DressObject(snapshot: item as! FIRDataSnapshot)
                let pathReference = FIRStorage.storage().reference(withPath: "dressImages/\((item as! FIRDataSnapshot).key).jpg")
                
                //Get the dress image
                //TODO: Get the profile image too
                _ = pathReference.data(withMaxSize: (1 * 512 * 512), completion: {
                    (data, error) -> Void in
                    if (error != nil) {
                        print("error occured \(error)")
                    }
                    else {
                        //Add image to a dictionary of key: Image
                        //self.photoDictionary[(item as! FIRDataSnapshot).key] = UIImage(data: data!)
                        newDress.image = UIImage(data: data!)
                    }
                })
                
                //Add image to an array of dresses (without images yet). Images get added once the data has been downloaded
                self.reelDressArray.append(newDress)
            }
        })
    }
    
    func matchPhotos() {
        /*for i in 0..<reelDressArray.count {
            //reelDressArray[i].image = photoDictionary[reelDressArray[i].key]
        }*/
    }
}

