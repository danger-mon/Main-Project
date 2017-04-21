//
//  PopViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 19/12/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit

class PopViewController: UIViewController {
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var theView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.message.alpha = 0.0
        button.alpha = 0.0
        theView.alpha = 0.0
        
        theView.layer.shadowRadius = 10
        theView.layer.shadowColor = UIColor.gray.cgColor
        theView.clipsToBounds = false
        theView.layer.shadowOpacity = 1
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedOk(_ sender: Any) {
        self.view.removeFromSuperview()
    }

}

class DeleteViewController: UIViewController {
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var theView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.message.alpha = 0.0
        button.alpha = 0.0
        theView.alpha = 0.0
        
        theView.layer.shadowRadius = 10
        theView.layer.shadowColor = UIColor.gray.cgColor
        theView.clipsToBounds = false
        theView.layer.shadowOpacity = 1
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedOk(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
}
