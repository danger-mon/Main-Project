//
//  ViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 03/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import OneSignal

class ViewController: UIViewController, TapDelegate3 {
    
    var draggableBackground: DraggableViewBackground!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.isTranslucent = false
        
        let image2: UIImage = #imageLiteral(resourceName: "envelope")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        button2.addTarget(self, action: #selector(messageScreen), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: button2)
        barButton2.addBadge(text: "\(BadgeHandler.messageBadgeNumber)")
        self.navigationItem.rightBarButtonItem = barButton2
        
        draggableBackground = DraggableViewBackground(frame: self.view.frame) //frame: CGRect(x: 0.0, y: 70.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width )
        draggableBackground.heightOfArea = Int(view.bounds.height - (navigationController?.navigationBar.frame.height)! - (tabBarController?.tabBar.frame.height)!)
        
        draggableBackground.delegate3 = self
        self.view.addSubview(draggableBackground)
        
        
    }
    
    func changeBadge() {
        if BadgeHandler.messageBadgeNumber != 0 {
            self.navigationItem.rightBarButtonItem?.setBadge(text: "\(BadgeHandler.messageBadgeNumber)")
        } else {
            self.navigationItem.rightBarButtonItem?.setBadge(text: "")
        }
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
        super.viewWillAppear(animated)
        /*
        if draggableBackground.loadOnView == true {
            draggableBackground.catchDressesFromServer()
        } else if draggableBackground.loadOnView == false {
            draggableBackground.loadOnView = true
        }*/
        changeBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeBadge()
    }
    
    override func setNeedsFocusUpdate() {
        //draggableBackground.loadBufferingCards()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didTapPhoto(sender: UITapGestureRecognizer) {
        let cardHandled = sender.view as! DraggableView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "pictureViewer") as! MultipleDressScreenViewController
        
        print(nextViewController.view.description)
        
        nextViewController.profileName.text = cardHandled.profileView.profileName.text
        nextViewController.profileImage.image = cardHandled.profileView.profileCircle.image
        nextViewController.locationLabel.text = cardHandled.profileView.location.text
        nextViewController.dressImagesCollectionView.currentPictures.append(cardHandled.dressImageView.image!)
        nextViewController.dressTitle.text = cardHandled.dressName.text
        nextViewController.dressDescription.text = cardHandled.dressDescription.text
        nextViewController.refToLoad = cardHandled.reference
        //nextViewController.dontDownload = true
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

}

