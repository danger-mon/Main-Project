//
//  SavedCollectionViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 07/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

private let reuseIdentifier = "Cell"

class SavedCollectionViewController: UICollectionViewController {
    
    struct imageAndReference {
        var image: UIImage = UIImage()
        var ref: String = ""
    }
    
    //MARK: Properties
    
    var savedDresses: [imageAndReference] = []
    var paddingSpace: Int = 0
    var availableWidth: Int = 0
    var widthPerItem: Int = 0
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 2.0, right: 0.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = ""
        
        let image2: UIImage = #imageLiteral(resourceName: "envelope")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        button2.addTarget(self, action: #selector(messageScreen), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: button2)
        self.navigationItem.rightBarButtonItem = barButton2
        
        paddingSpace = Int(sectionInsets.left) * 3 + 2
        availableWidth = Int(self.view.frame.width) - paddingSpace
        widthPerItem = availableWidth / 2
        
        self.collectionView?.contentInset = UIEdgeInsets(top: 2.0  , left: 0.0, bottom: 2.0 , right: 0.0)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: widthPerItem, height: widthPerItem)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        collectionView!.collectionViewLayout = layout
        
    }
    
    func messageScreen() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "conversations")
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(vc!, animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        
        if BadgeHandler.messageBadgeNumber != 0 {
            self.navigationItem.rightBarButtonItem?.setBadge(text: "\(BadgeHandler.messageBadgeNumber)")
        } else {
            self.navigationItem.rightBarButtonItem?.setBadge(text: "")
        }
        loadDresses()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return savedDresses.count
    }
    /*
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "title", for: indexPath)
            return headerView
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
            return footerView

        default:
            assert(false, "Unexpected element kind")
        }
    }
    */

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SavedCollectionViewCell
        
        let dress = savedDresses[indexPath.row]
        
        cell.cellImage.image = dress.image
        cell.ref = dress.ref
        
        cell.cellImage.contentMode = .scaleAspectFill
        cell.cellImage.clipsToBounds = true
        cell.layer.bounds = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height)
        cell.backgroundView = UIImageView(image: dress.image)
        let gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(showPopUpMessage))
        cell.addGestureRecognizer(gestureRecogniser)
        cell.alpha = 1
        /*if( cell.subviews.count < 3)
        {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = cell.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cell.insertSubview(blurEffectView, aboveSubview: cell.backgroundView!)
        }*/
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /*UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            (cell as! SavedCollectionViewCell).alpha = 1
        }, completion: nil) */

    }
    
    func showPopUpMessage(sender: UIGestureRecognizer) {
        
        let databaseRef = FIRDatabase.database().reference().child("Users").child((FIRAuth.auth()?.currentUser?.uid)!)
        
        if sender.state == .began {
            
            let cell = sender.view as! SavedCollectionViewCell
            
            let alert = UIAlertController(title: "Options", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    self.savedDresses.remove(at: (self.collectionView?.indexPath(for: cell))!.row)
                    //print(databaseRef.child("savedDresses").child(cell.ref).description())
                    databaseRef.child("savedDresses").child(cell.ref).removeValue()
                    FIRDatabase.database().reference().child("PostData").child(cell.ref).child("swipedRight").child((FIRAuth.auth()?.currentUser?.uid)!).removeValue()
                    
                    self.collectionView?.reloadData()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
                switch action.style{
                case .cancel:
                    print("cancel")
                default: break
                    
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
            
                /*let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popup") as! PopViewController
                self.addChildViewController(vc)
                vc.view.frame = self.view.frame
                self.view.addSubview(vc.view)
                vc.didMove(toParentViewController: self)
                
                UIView.animate(withDuration: 0.4, animations: {
                    vc.message.alpha = 1
                    vc.button.alpha = 1
                    vc.theView.alpha = 1
                })
                
                vc.message.text = "Delete Text?"
             */
        }
    }
    
    func loadDresses() //-> [DressObject]?
    {
        let currentUser = (FIRAuth.auth()?.currentUser?.uid)!
        let databaseRef = FIRDatabase.database().reference()
        
        
        //TODO: Make this be able to reload more
        databaseRef.child("Users").child(currentUser).child("savedDresses").queryOrderedByValue().observe(.childAdded, with: {
            
        snapshot in
            
            if snapshot.value is NSNull {
                print("Nothing in there")
            } else {
                
                
                let ref = snapshot.key
                
                let newDress: imageAndReference = imageAndReference(image: #imageLiteral(resourceName: "loading"), ref: ref)
                
                var repeated = false
                
                for item in self.savedDresses{
                    
                    if newDress.ref == (item.ref) {
                        repeated = true
                    }
                }
                    
                if repeated == false {
                    
                    self.savedDresses.insert(newDress, at: 0)
                    //self.collectionView?.reloadData()
                    
                    let storageRef = FIRStorage.storage().reference().child("dressImages/\(ref)/1.jpg")
                    storageRef.data(withMaxSize: (2 * 1024 * 1024), completion: { (data, error) in
                        for i in 0..<self.savedDresses.count {
                            if self.savedDresses[i].ref == ref {
                                if data != nil {
                                    self.savedDresses[i].image = UIImage(data: data!)!
                                    self.collectionView?.reloadData()
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "dressSegue") {
            
            let svc = segue.destination as! MultipleDressScreenViewController;
            let dressSender = sender as! SavedCollectionViewCell
            let _ = svc.view.description
            
            svc.isHeroEnabled = true
            self.navigationController?.isHeroEnabled = true
            svc.dressImagesCollectionView.heroID = "image"
            dressSender.heroID = "image"
            self.isHeroEnabled = true
            
            svc.refToLoad = dressSender.ref
            svc.dressImagesCollectionView.currentPictures = []
            svc.dressImagesCollectionView.currentPictures.append(dressSender.cellImage.image!)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        for cell in (collectionView?.visibleCells)! {
            cell.heroID = ""
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
}



extension SavedCollectionViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width:collectionView.frame.size.width, height: 0.0)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

