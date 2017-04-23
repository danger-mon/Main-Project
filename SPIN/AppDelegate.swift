//
//  ViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 03/11/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//


import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSPermissionObserver, OSSubscriptionObserver {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        
        /*if UserDefaults.standard.string(forKey: "messageBadgeNumber") != nil {
            BadgeHandler.messageBadgeNumber = Int(UserDefaults.standard.string(forKey: "messageBadgeNumber")!)!
        }*/
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            print("Received Notification: \(notification!.payload.body)")
            
            if notification?.payload.additionalData != nil {
                if notification?.payload.additionalData["type"] != nil {
                    if notification?.payload.additionalData["type"] as! String == "request" {
                        
                    }
                } else {
                    //Message Notification
                    if notification?.payload.additionalData["userID"] != nil {
                        let incomingKey = notification?.payload.additionalData["userID"] as! String
                        if BadgeHandler.messages[incomingKey] == nil {
                            BadgeHandler.messages[incomingKey] = 1
                        } else {
                            BadgeHandler.messages[incomingKey]! += 1
                        }
                    }
                }
                
            }
            //BadgeHandler.messageBadgeNumber += 1
            
            /*
            let topController = UIApplication.shared.keyWindow!.rootViewController!.topMostViewController()
            
            if BadgeHandler.messageBadgeNumber == 0 {
                topController.navigationItem.rightBarButtonItem?.setBadge(text: "")
            } else {
                topController.navigationItem.rightBarButtonItem?.setBadge(text: "\(BadgeHandler.messageBadgeNumber)")
            } */
            /*
            if topController is ViewController {
                (topController as! ViewController).changeBadge()
            } else if topController is ProfileViewController {
                (topController as! ProfileViewController).navigationItem.rightBarButtonItem?.setBadge(text:  "\(BadgeHandler.messageBadgeNumber)")
            } else if topController is SavedCollectionViewController {
                (topController as! SavedCollectionViewController).navigationItem.rightBarButtonItem?.setBadge(text:  "\(BadgeHandler.messageBadgeNumber)")
            } else if topController is UploadViewController {
                (topController as! UploadViewController).navigationItem.rightBarButtonItem?.setBadge(text:  "\(BadgeHandler.messageBadgeNumber)")
            } else if topController is RequestsTableViewController {
                (topController as! RequestsTableViewController).navigationItem.rightBarButtonItem?.setBadge(text:  "\(BadgeHandler.messageBadgeNumber)")
            } else if topController is MultipleDressScreenViewController {
                (topController as! MultipleDressScreenViewController).navigationItem.rightBarButtonItem?.setBadge(text:  "\(BadgeHandler.messageBadgeNumber)")
            } */
        }
        
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            
            var fullMessage = payload.body
            print("Message = \(String(describing: fullMessage!))")
            print(payload.debugDescription)
            
            if payload.additionalData != nil {
                if payload.title != nil {
                    let messageTitle = payload.title
                    print("Message Title = \(messageTitle!)")
                }
                
                let additionalData = payload.additionalData
                if additionalData?["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonID: \(String(describing: additionalData!["actionSelected"]))"
                }
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: true,
                                     kOSSettingsKeyInAppLaunchURL: true]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "9e4404c7-fdfa-42fc-adb7-5930f2924b09",
                                        handleNotificationReceived: notificationReceivedBlock, 
                                        handleNotificationAction: notificationOpenedBlock, 
                                        settings: onesignalInitSettings)
        
                
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.none
        
        OneSignal.add(self as OSPermissionObserver)
        
        OneSignal.add(self as OSSubscriptionObserver)

        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    
        return true
    }
    
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        
        // Example of detecting answering the permission prompt
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        // prints out all properties
        print("PermissionStateChanges: \n\(stateChanges)")
    }
    
    // Output:
    /*
     Thanks for accepting notifications!
     PermissionStateChanges:
     Optional(<OSSubscriptionStateChanges:
     from: <OSPermissionState: hasPrompted: 0, status: NotDetermined>,
     to:   <OSPermissionState: hasPrompted: 1, status: Authorized>
     >
     */
    
    // TODO: update docs to change method name
    // Add this new method
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
    }
    
    // Output:
    
    /*
     Subscribed for OneSignal push notifications!
     PermissionStateChanges:
     Optional(<OSSubscriptionStateChanges:
     from: <OSSubscriptionState: userId: (null), pushToken: 0000000000000000000000000000000000000000000000000000000000000000 userSubscriptionSetting: 1, subscribed: 0>,
     to:   <OSSubscriptionState: userId: 11111111-222-333-444-555555555555, pushToken: 0000000000000000000000000000000000000000000000000000000000000000, userSubscriptionSetting: 1, subscribed: 1>
     >
     */
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let _: OSHandleNotificationReceivedBlock = { notification in
            print("Received Notification: \(notification!.payload.notificationID)")
        }
        
        let _: OSHandleNotificationActionBlock = { result in
            
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            
            var fullMessage = payload.body
            print("Message = \(String(describing: fullMessage!))")
            
            if payload.additionalData != nil {
                if payload.title != nil {
                    let messageTitle = payload.title
                    print("Message Title = \(messageTitle!)")
                }
                
                let additionalData = payload.additionalData
                if additionalData?["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonID: \(String(describing: additionalData!["actionSelected"]))"
                }
            }
        }

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
}

