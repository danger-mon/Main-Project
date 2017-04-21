//
//  ChatNavigationController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 22/12/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit

class ChatNavigationController: UINavigationController {

    var logoView: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent = false
        
        self.navigationBar.barTintColor = UIColor(red: 41/255, green: 37/255, blue: 47/255, alpha: 1)
        navigationBar.tintColor = UIColor.white
        let logo = UIImage(named: "SPIN")
        logoView = UIImageView(image: logo)
        logoView.frame = CGRect(x: (Int(UIScreen.main.bounds.width/2) - 50), y: 0, width: 100, height: 50)
        logoView.contentMode = .scaleAspectFit
        //self.navigationBar.addSubview(logoView)
        navigationBar.backIndicatorImage = #imageLiteral(resourceName: "left-arrow")
        navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "left-arrow")
        navigationBar.backItem?.title = ""
        navigationBar.barStyle = UIBarStyle.black
        navigationBar.tintColor = UIColor.white
        
        let image2: UIImage = #imageLiteral(resourceName: "envelope")
        let button2: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button2.setImage( image2, for: .normal)
        
        let barButton2 = UIBarButtonItem(customView: button2)
        self.navigationItem.rightBarButtonItem = barButton2
        
        UINavigationBar.appearance().alpha = 1
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
}
