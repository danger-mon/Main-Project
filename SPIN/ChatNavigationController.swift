//
//  ChatNavigationController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 22/12/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit

class ChatNavigationController: UINavigationController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent = false
        
        self.navigationBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        navigationBar.tintColor = UIColor.black
        
        //self.navigationBar.addSubview(logoView)
        navigationBar.backIndicatorImage = #imageLiteral(resourceName: "left-arrow")
        navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "left-arrow")
        navigationBar.backItem?.title = ""
        
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
