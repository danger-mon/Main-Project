//
//  MultipleDressCollectionView.swift
//  SPIN
//
//  Created by Pelayo Martinez on 10/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit


class MultipleDressCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let reuseIdentifier2 = "picture"
    var tapRecogniser: UITapGestureRecognizer? = nil
    var tapRecognisers: [UITapGestureRecognizer] = []
    var areCellsInteractable = false
    
    var currentPictures: [UIImage] = []
    var paddingSpace: Float = 0
    var availableWidth: Float = 0
    var widthPerItem: Float = 0
    var isItUpload = false

    fileprivate let sectionInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        currentPictures = [#imageLiteral(resourceName: "claire"), #imageLiteral(resourceName: "claire"), #imageLiteral(resourceName: "claire")]
        
        paddingSpace = 0 //Float(sectionInsets.left) * Float(2)
        availableWidth = 0 //Float(UIScreen.main.bounds.width) - paddingSpace
        
        self.layer.shadowOpacity = 0
        
        dataSource = self
        delegate = self
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (currentPictures.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "picture", for: indexPath) as! MultipleDressCollectionViewCell
        
        cell.cellImage.image = currentPictures[indexPath.row]
        cell.id = indexPath.row
        cell.cellImage.contentMode = .scaleAspectFill
        cell.cellImage.clipsToBounds = true
        cell.contentMode = .scaleAspectFill
        
        if areCellsInteractable {
            cell.isUserInteractionEnabled = true
            if tapRecognisers[cell.id] != nil {
                cell.addGestureRecognizer(tapRecognisers[cell.id])
            }
        } else {
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isItUpload {
            widthPerItem = Float(self.bounds.height)
        } else {
            widthPerItem = Float(self.bounds.width) //availableWidth / 2
        }
        
        return CGSize(width: Int(widthPerItem), height: Int(widthPerItem))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /*
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            cell.alpha = 1
        }, completion: nil)
*/
    }
    
    /*
     func collectionView(_ collectionView: UICollectionView,
     layout collectionViewLayout: UICollectionViewLayout,
     insetForSectionAt section: Int) -> UIEdgeInsets {
     return sectionInsets
     }*/
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

}
