//
//  BadgeHandler.swift
//  SPIN
//
//  Created by Pelayo Martinez on 21/04/2017.
//  Copyright © 2017 Pelayo Martinez. All rights reserved.
//

import UIKit

class BadgeHandler: NSObject {
    
    
    static var messageBadgeNumber = 0 {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set("\(messageBadgeNumber)", forKey: "messageBadgeNumber")
            if messageBadgeNumber == 0 {
                UIApplication.shared.keyWindow!.rootViewController!.topMostViewController().navigationItem.rightBarButtonItem?.setBadge(text: "")
            } else {
                if UIApplication.shared.keyWindow != nil {
                    UIApplication.shared.keyWindow!.rootViewController!.topMostViewController().navigationItem.rightBarButtonItem?.setBadge(text: "\(messageBadgeNumber)")
                }
            }
        }
    }
    static var messages: [String: Int] = [:] {
        didSet {
            print("setting \(messages)")
            var count = 0
            for (_, value) in messages {
                count += value
            }
            messageBadgeNumber = count
        }
    }
    
    static var requestsNumber = 0 {
        didSet {
            print("editing tags")
            let controller = UIApplication.shared.keyWindow!.rootViewController!.topMostViewController()
            controller.navigationController?.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = "\(requestsNumber)"
        }
    }

}
