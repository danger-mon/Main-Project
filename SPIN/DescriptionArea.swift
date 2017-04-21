//
//  DescriptionArea.swift
//  SPIN
//
//  Created by Pelayo Martinez on 04/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit

class DescriptionArea {
    
    var dressName: UILabel!
    var dressDescription: UITextView!
    let CARD_HEIGHT = (UIScreen.main.bounds.width - 100)
    let CARD_WIDTH = (UIScreen.main.bounds.width - 100)
    var dressTitles: [String]
    var descriptions: [String]

    init () {
        dressTitles = []
        descriptions = []
        
        //Creates a label for the dress Title
        dressName = UILabel(frame: CGRect(x: 35 , y: 3/2*CARD_HEIGHT + 10 , width: CARD_WIDTH, height: 50))
        dressName.text = "" //.uppercased()
        dressName.textColor = UIColor.black
        dressName.textAlignment = .left
        dressName.font = UIFont(name: "Avenir", size: 25.0)
        
        //Creates a label for the dress description
        dressDescription = UITextView(frame: CGRect(x: 31 , y: 3/2*CARD_HEIGHT + 45 , width: CARD_WIDTH, height: 100))
        dressDescription.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0)
        dressDescription.text = ""
        dressDescription.textColor = UIColor.darkGray
        dressDescription.font = UIFont(name: "Avenir", size: 12.0)
        dressDescription.textAlignment = .left
        dressDescription.allowsEditingTextAttributes = false
    }
    
    func setArrays(name: String,dressDescription: String) {
        self.dressTitles.append(name)
        self.descriptions.append(dressDescription)
    }
    
}
