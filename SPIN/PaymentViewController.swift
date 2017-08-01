//
//  PaymentViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 27/07/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit
import Stripe
import FirebaseDatabase

class PaymentViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var expiryDateField: UITextField!
    @IBOutlet weak var cvcField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func donate(_ sender: Any) {
        let stripCard = STPCard()
        let expirationDate = expiryDateField.text?.components(separatedBy: "/")
        let expMonth = UInt(Int((expirationDate?[0])!)!)
        let expYear = UInt(Int((expirationDate?[1])!)!)
        stripCard.number = cardNumberField.text
        stripCard.cvc = cvcField.text
        stripCard.expMonth = expMonth
        stripCard.expYear = expYear
        
        STPAPIClient.shared().createToken(withCard: stripCard) { (token, error) in
            if error != nil {
                self.handleError(error: error as! NSError)
                return
            }
            self.postStripeToken(token: token!)
        }
    }
    
    func handleError(error: NSError) {
        UIAlertView(title: "Please Try Again", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func postStripeToken(token: STPToken) {
        let params = ["stripeToken": token.tokenId,
                      "amount": Int(self.amountField.text!),
                      "currency": "gbp",
                      "description": self.emailField.text] as [String : Any]
        FIRDatabase.database().reference().child("stripe_customers").child("qWPqHJ3nHjUNhZmyqEobNVh360g2").child("charges")
    }
}
