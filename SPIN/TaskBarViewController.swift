//
//  TaskBarViewController.swift
//  TinderSwipeCardsSwift
//
//  Created by Pelayo Martinez on 03/11/2016.
//  Copyright © 2016 gcweb. All rights reserved.
//

import UIKit

class TaskBarViewController: UINavigationController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationBar.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: 90)
       /* self.navigationBar.barTintColor = UIColor(red: 170/255, green: 211/255, blue: 211/255, alpha: 1)
        self.navigationItem.title = "SPIN"
        let logo = UIImage(named: "SPIN")
        let logoView = UIImageView(image: logo)
        logoView.frame = CGRect(x: (Int(UIScreen.main.bounds.width/2) - 50), y: 0, width: 100, height: 50)
        logoView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logoView
        self.navigationItem.title = "SPIN"
        self.navigationBar.addSubview(logoView)
        
        UINavigationBar.appearance().alpha = 1 */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
