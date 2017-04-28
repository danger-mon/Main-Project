//
//  savedControllerViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 18/12/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit

class genericControllerViewController: UINavigationController {

    var logoView: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*self.navigationBar.isTranslucent = false*/

        self.navigationBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        let logo = #imageLiteral(resourceName: "logoone")
        logoView = UIImageView(image: logo)
        logoView.frame = CGRect(x: (Int(UIScreen.main.bounds.width/2) - 35), y: Int(0.75 * (self.navigationBar.bounds.height - 35)), width: 70, height: 35)
        logoView.contentMode = .scaleAspectFit
        self.navigationBar.addSubview(logoView)
        
        /*
        var backButtonImage = UIImage(named: "left-arrow")
        //backButtonImage = backButtonImage?.stretchableImage(withLeftCapWidth: 15, topCapHeight: 30)
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(backButtonImage, for: .normal, barMetrics: .default) */
        
        
        navigationBar.backIndicatorImage = #imageLiteral(resourceName: "left-arrow")
        navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "left-arrow")
        navigationBar.backItem?.title = " "
        navigationBar.tintColor = UIColor.black
        
        
        let image2: UIImage = #imageLiteral(resourceName: "envelope")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        button2.addTarget(self, action: #selector(messageScreen), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: button2)
        self.navigationItem.rightBarButtonItem = barButton2
        
        UINavigationBar.appearance().alpha = 1

    }
    
    func messageScreen() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "conversations")
        vc?.modalTransitionStyle = .flipHorizontal
        self.present(vc!, animated: true, completion: nil)
    }
    func addTapped() {
        print("hello")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
