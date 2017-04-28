//
//  ReportViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 25/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ReportViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    var options = ["Impersonation", "Abusive Content", "Harassment", "Pornographic Content", "Illicit Content", "Other"]
    @IBOutlet weak var additionalComments: UITextView!
    var selected = ""
    @IBOutlet weak var submitButton: UIButton!
    var dressRef = ""
    var ownerUid = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        additionalComments.layer.cornerRadius = 7
        additionalComments.layer.borderWidth = 1
        additionalComments.layer.borderColor = UIColor.darkGray.cgColor
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.reloadAllComponents()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected = options[row]
    }
    @IBAction func submit(_ sender: Any) {
        let post = ["user": (FIRAuth.auth()?.currentUser?.uid)!,
                    "username": ProfileViewController.ownUsername,
                    "dressRef": dressRef,
                    "ownerUid": ownerUid,
                    "reason": selected,
                    "comments": additionalComments.text!] as [String : Any]
        FIRDatabase.database().reference().child("Reports").childByAutoId().setValue(post)
        self.navigationController?.popViewController(animated: true)
    }

}
