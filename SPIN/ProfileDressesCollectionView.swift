//
//  ProfileDressesCollectionViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 14/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class ProfileDressesCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    //var currentDresses: [DressObject]? = []
    var currentDresses: [(UIImage, String, String)] = []
    var paddingSpace: Float = 0
    var availableWidth: Float = 0
    var widthPerItem: Float = 0
    weak var delegate2: LongPressDelegate?

    fileprivate let sectionInsets = UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        currentDresses = []   
        
        print(self.bounds.width)
        print(UIScreen.main.bounds.width)
        paddingSpace = Float(sectionInsets.left) * Float (4)
        availableWidth = Float(UIScreen.main.bounds.width) - paddingSpace
        widthPerItem = availableWidth / 3
        print(widthPerItem)
        
        self.layer.shadowOpacity = 0
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: Int(widthPerItem), height: Int(widthPerItem))
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        collectionViewLayout = layout
        
        dataSource = self
        delegate = self
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (currentDresses.count)
    }
    /*
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            (cell as! OwnDressesCollectionViewCell).alpha = 1
        }, completion: nil)
    }
    */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OwnDressesCollectionViewCell
        
        cell.cellImage.image = currentDresses[indexPath.row].0
        
        cell.cellImage.contentMode = .scaleAspectFill
        cell.cellImage.clipsToBounds = true
        
        cell.reference = currentDresses[indexPath.row].1
        cell.uid = currentDresses[indexPath.row].2
        
        if currentDresses[indexPath.row].2 == FIRAuth.auth()?.currentUser?.uid {
            let gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(showPopUpMessage))
            cell.addGestureRecognizer(gestureRecogniser)
        }
        
        cell.contentMode = .scaleAspectFill
        var counting = Int(currentDresses.count / 3)
        if currentDresses.count % 3 != 0 {
            counting += 1
        }
        
        delegate2?.updateSize(size: counting * Int(widthPerItem) + Int(contentInset.top))
 
        delegate2?.updateListings()
        //self.sizeToFit()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(widthPerItem), height: Int(widthPerItem))
    }
    
    func showPopUpMessage(sender: UIGestureRecognizer) {
        delegate2?.didLongPressCell(sender: sender)
    }
}

protocol LongPressDelegate: class {
    
    func didLongPressCell(sender: UIGestureRecognizer)
    func updateSize(size: Int)
    func updateListings()
}
