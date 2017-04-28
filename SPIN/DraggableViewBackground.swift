//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import OneSignal

class DraggableViewBackground: UIView, DraggableViewDelegate, UIGestureRecognizerDelegate {
    
    //MARK: Properties
    
    var exampleCardLabels: [String]!
    var allCards: [DraggableView]!
    var loadedCardData: [DressObject]!
    var descriptionAreaView: DescriptionArea!
    var dressReel: [DressObject]!
    var savedDressReferences: [String]!
    var viewedDressReferences: [String]!
    let initialLoad = 3
    var myCount = 0
    weak var delegate3: TapDelegate3?
    var heightOfArea = 0
    
    var reloadButton: UIButton!
    var loadingLabel: UILabel!

    /*var toCome = 0 {
        didSet {
            if toCome == 1 {
                if dressReel.count >= 2 {
                    self.catchNextDress(count: 1)
                }
            } else if toCome == 2 {
                if dressReel.count >= 1 {
                    self.catchNextDress(count: 1)
                }
            } else if toCome == 3 {
                if dressReel.count >= 0 {
                    <#code#>
                }
            }
        }
    } */
    
    let MAX_BUFFER_SIZE = 2
    let CARD_HEIGHT: CGFloat = UIScreen.main.bounds.width - 10 + 150
    let CARD_WIDTH: CGFloat = UIScreen.main.bounds.width - 10
    var timestamp: Int32 = 0 {
        didSet {
            if dressReel.count < 3 {
               // catchNextDress(count: 1)
            }
        }
    }
    var currentTime: Double = NSDate.timeIntervalSinceReferenceDate
    var upperBound: Int64 = 0 //Consider changing int64
    var lowerBound: Int64 = 0
    
    var cardsLoadedIndex: Int!
    var loadedCards: [DraggableView]!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    var dressName: UILabel!
    var dressDescription: UITextView!
    var nameFont: UIFont!
    var profileView: MiniProfile!
    var currentDressIndex: Int!
    var profileArray: [String]!
    var profilePhotos: [UIImage]!
    var user: FIRUser? = nil
    var loadOnView: Bool = false
    var nextTimeSegment: (Double, Double) = (0,0)
    var currentTimeSegment: (Double, Double) = (0,0)
    var currentTimeSegmentKey: String = ""
    var nextTimeSegmentKey: String = ""
    var endOfSegment = false

    //MARK: Initialization
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        currentTimeSegment.0 = currentTime
        currentTimeSegment.1 = currentTime
        
        user = FIRAuth.auth()?.currentUser
        savedDressReferences = []
        viewedDressReferences = []
        profileArray = []
        profilePhotos = []
        dressReel = []
        loadedCards = []
        //savedDressReel = []
        currentDressIndex = 0
        super.layoutSubviews()
        
        let databaseRef = FIRDatabase.database().reference()
        
        // Obtain the most recent time segment
        let query = databaseRef.child("timeSegments").child((FIRAuth.auth()?.currentUser?.uid)!).queryOrdered(byChild: "upper").queryLimited(toLast: 1)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            // If there isn't one set one to (0,0)
            if snapshot.value is NSNull {
                let newDict = ["upper": 0,
                               "lower": 0]
                databaseRef.child("timeSegments").child((FIRAuth.auth()?.currentUser?.uid)!).childByAutoId().setValue(newDict)
                self.nextTimeSegment = (0,0)
                
            //If there is, store it in timeSegment
            } else {
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    let segment1 = rest.value as! [String: NSNumber]
                    self.nextTimeSegment = (Double(segment1["upper"]!), Double(segment1["lower"]!))
                    self.nextTimeSegmentKey = rest.key
                }
            }
            if FIRAuth.auth()?.currentUser?.uid != nil {
                self.currentTimeSegmentKey = databaseRef.child("timeSegments").child((FIRAuth.auth()?.currentUser?.uid)!).childByAutoId().key
            }
            //self.catchNextDress(count: 3)
            //self.toCome = 3
            self.catchNextDress(count: 1, time: self.currentTime, start: true)
        })
        
        FIRDatabase.database().reference().child("Users/\((FIRAuth.auth()?.currentUser?.uid)!)/conversations").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value is NSNull { } else {
                let dictionary: [String: [String: Any]] = snapshot.value as! [String: [String: Any]]
                var conversationUnseens: [String: Int] = [:]
                for (_, value) in dictionary {
                    conversationUnseens[value["uid"] as! String] = (value["unseen"])! as? Int
                }
                BadgeHandler.messages = conversationUnseens
            }
        })
        
        FIRDatabase.database().reference().child("Users/\((FIRAuth.auth()?.currentUser?.uid)!)/incomingRequests").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { } else {
                let counter = snapshot.value as! NSDictionary
                BadgeHandler.requestsNumber = counter.count
            }
        })
        
        loadingLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 20, width: 100, height: 40))
        loadingLabel.center = self.center
        loadingLabel.text = ""
        loadingLabel.isEnabled = false
        loadingLabel.isHidden = true
        loadingLabel.bounds = CGRect(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height / 2) - (loadingLabel.bounds.width/2) , width: 100, height: 40)
        self.addSubview(loadingLabel)
        
        self.setupView()
        allCards = []
        cardsLoadedIndex = 0
        
        
        if user?.displayName != nil {
            Profile.ownUsername = (user?.displayName)!
        }
        
        self.loadingLabel.isEnabled = false
        self.loadingLabel.isHidden = true
        //descriptionAreaView = DescriptionArea()
    }
    

    //MARK: Setting up View
    func setupView() -> Void {
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        //Button to Reject
        xButton = UIButton(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2 + 35, y: self.frame.size.height/2 + CARD_HEIGHT/2 + 10, width: 59, height: 59))
        xButton.setImage(UIImage(named: "xButton"), for: UIControlState())
        xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), for: UIControlEvents.touchUpInside)

        //Button to Accept
        checkButton = UIButton(frame: CGRect(x: self.frame.size.width/2 + CARD_WIDTH/2 - 85, y: self.frame.size.height/2 + CARD_HEIGHT/2 + 10, width: 59, height: 59))
        checkButton.setImage(UIImage(named: "checkButton"), for: UIControlState())
        checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), for: UIControlEvents.touchUpInside)
        
        //Creates a label for the dress Title
        //dressName = UILabel(frame: CGRect(x: 23 , y: 3/2*CARD_HEIGHT - 34 , width: CARD_WIDTH, height: 50))
        dressName = UILabel(frame: CGRect(x: 10 , y: CARD_HEIGHT , width: CARD_WIDTH, height: 50))
        dressName.text = "" //.uppercased()
        dressName.textColor = UIColor.black
        dressName.textAlignment = .left
        dressName.font = UIFont(name: "Avenir", size: 18.0)
    
        //Creates a label for the dress description
        //dressDescription = UITextView(frame: CGRect(x: 19 , y: 3/2*CARD_HEIGHT - 5 , width: CARD_WIDTH, height: 100))
        dressDescription = UITextView(frame: CGRect(x: 6 , y: CARD_HEIGHT + 30, width: CARD_WIDTH, height: 100))
        dressDescription.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0)
        dressDescription.text = ""
        dressDescription.textColor = UIColor.darkGray
        dressDescription.font = UIFont(name: "Avenir", size: 10.0)
        dressDescription.textAlignment = .left
        dressDescription.allowsEditingTextAttributes = false
        dressDescription.isEditable = false
        
        //Creates the profile display
        profileView = MiniProfile()
        
    }

    
    
    //Initialize the photo view to then add all the new ones
    func createDraggableViewWithDataAtIndex(_ index: NSInteger) -> DraggableView {
        
        let draggableView = DraggableView(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2 , y: (CGFloat(heightOfArea) - CARD_HEIGHT - 15)/2, width: CARD_WIDTH, height: CARD_HEIGHT))
        draggableView.information.text = ""
        
        draggableView.delegate = self
        return draggableView
    }
    
    
    //Adds a card by default
    func addDefaultCards() {
        /* print(dressReel.count)
         
         for m in 0..<dressReel.count {
         let name = dressReel[m].name
         let description = dressReel[m].dressDescription
         let profileName = dressReel[m].profile
         let profilePhoto = dressReel[m].profilePhoto
         
         let newCard: DraggableView = self.createDraggableViewWithDataAtIndex(m) //Create draggable view card to store the new image
         newCard.dressImageView.image = dressReel[m].image //Get the image from the data loader array
         loadedCards.append(newCard) // Put in loaded cards array
         
         profileArray.append(profileName!)
         profilePhotos.append(profilePhoto!)
         
         descriptionAreaView.setArrays(name: name!, dressDescription: description!)
         }
         for m in 0..<loadedCards.count {
         if m > 0 {
         self.insertSubview(loadedCards[m], belowSubview: loadedCards[m - 1]) //Insert the 2nd to nth view behind the main one
         } else {
         self.addSubview(loadedCards[m]) //Insert the first visible image on top
         }
         }*/
    }
    
    func createCircle() -> CAShapeLayer{
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2), radius: CGFloat(20), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.red.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 3.0
        
        return shapeLayer
    }
    
    
    func catchNextDress(count: Int, time: Double, start: Bool) {
        
        // If the current time is between the time of launch and the time of first segment (newest unseen dresses)
            
        
            let databaseRef = FIRDatabase.database().reference()
            // Of the children between the current time and the nearest segment upper bound get the most recent
            
            print("between:\(nextTimeSegment.0) and \(time)")
            
            let query = databaseRef.child("Posts").queryOrdered(byChild: "timestamp").queryStarting(atValue: nextTimeSegment.0).queryEnding(atValue: (time - 1)).queryLimited(toLast: 3)
            
            query.observeSingleEvent(of: .value, with: { (snapshot) in
            
                if snapshot.value is NSNull {
                    
                    self.updateSegments(joining: true)
                    /*
                    if self.nextTimeSegment.0 == 0 {
                        if count == 1 && self.dressReel.count == 0 {
                            self.endOfSegment = true
                            self.updateSegments(joining: true) // Not sure
                        }
                    } else {
                        print("updateSegments joining: false")
                        if self.nextTimeSegment.0 == 0 {
                            if count == 1 && self.dressReel.count == 0 {
                                self.endOfSegment = true
                                self.updateSegments(joining: true) // Not sure
                            }
                        }
                    }*/
                    
                } else {
                    
                    var snapshots: [FIRDataSnapshot] = []
                    for child in snapshot.children {
                        snapshots.append(child as! FIRDataSnapshot)
                    }
                    var snapshots2: [FIRDataSnapshot] = []
                    var count = snapshots.count
                    while count > 0 {
                        snapshots2.append(snapshots[count - 1])
                        count -= 1
                    }
                    
                    let dresses = self.dressReel.count
                    
                    if start {
                        
                    for i in dresses..<snapshots2.count {
                    
                        var seen = false
                        for card in self.loadedCards {
                            if snapshots2[i].key == card.reference {
                                seen = true
                            }
                        }
                        
                        if !seen {
                            let item = snapshots2[i]
                            let newDress = DressObject(snapshot: item)
                            
                            self.dressReel.append(newDress)
                            
                            //Create a Draggable Card with all the properties of the dress
                            let position = self.loadedCards.count
                            let newDraggableCard: DraggableView = self.createDraggableViewWithDataAtIndex(position)
                            newDraggableCard.reference = newDress.ref!
                            newDraggableCard.getOwnImage()
                            newDraggableCard.dressName.text = newDress.name
                            newDraggableCard.dressDescription.text = newDress.dressDescription
                            newDraggableCard.profileView.profileName.text = newDress.profile
                            newDraggableCard.profileView.location.text = newDress.location
                            if let data = NSData(contentsOf: newDress.url as URL) {
                                newDraggableCard.profileView.profileCircle.image = UIImage(data: data as Data)!
                            }
                            newDraggableCard.backgroundColor = UIColor.white
                            newDraggableCard.tapDelegate = self
                            self.loadedCards.append(newDraggableCard)
                            
                            // Insert the cards into the view
                            if self.loadedCards.count == 1 {
                                self.insertSubview(self.loadedCards.last!, at: 0)
                            } else {
                                self.insertSubview(self.loadedCards.last!, belowSubview: self.loadedCards[position - 1]) //Insert the 2nd to nth view behind the main one
                            }
                            
                            self.currentTimeSegment.1 = Double(newDress.timestamp)
                        } else {
                            
                            self.endOfSegment = true
                        }
                    }
                    
                    } else {
                        var seen = false
                        for card in self.loadedCards {
                            if snapshots[0].key == card.reference {
                                seen = true
                            }
                        }
                        if !seen {
                            
                            let item = snapshots[0]
                            let newDress = DressObject(snapshot: item)
                            
                            self.dressReel.append(newDress)
                            
                            //Create a Draggable Card with all the properties of the dress
                            let position = self.loadedCards.count
                            let newDraggableCard: DraggableView = self.createDraggableViewWithDataAtIndex(position)
                            newDraggableCard.reference = newDress.ref!
                            newDraggableCard.getOwnImage()
                            newDraggableCard.dressName.text = newDress.name
                            newDraggableCard.dressDescription.text = newDress.dressDescription
                            newDraggableCard.profileView.profileName.text = newDress.profile
                            newDraggableCard.profileView.location.text = newDress.location
                            if let data = NSData(contentsOf: newDress.url as URL) {
                                newDraggableCard.profileView.profileCircle.image = UIImage(data: data as Data)!
                            }
                            newDraggableCard.backgroundColor = UIColor.white
                            newDraggableCard.tapDelegate = self
                            self.loadedCards.append(newDraggableCard)
                            
                            // Insert the cards into the view
                            if self.loadedCards.count == 1 {
                                self.insertSubview(self.loadedCards.last!, at: 0)
                            } else {
                                self.insertSubview(self.loadedCards.last!, belowSubview: self.loadedCards[position - 1]) //Insert the 2nd to nth view behind the main one
                            }
                            
                            self.currentTimeSegment.1 = Double(newDress.timestamp)
                        } else {
                            self.endOfSegment = true
                        }
                    }
                    
                }
                if count > 1 {
                    //self.catchNextDress(count: count - 1)
                }
            })
    }
    
    func updateSegments(joining: Bool) {
        
        //Buckets joined
        //Delete currentSegment, adjust upper value of nextSegment to encompass the area of the two old segments
        if joining {
            var fanoutObject: [String: AnyObject] = [:]
            let topValue = currentTimeSegment.0
            fanoutObject["/timeSegments/\((user?.uid)!)/\(currentTimeSegmentKey)"] = NSNull()
            fanoutObject["/timeSegments/\((user?.uid)!)/\(nextTimeSegmentKey)/upper"] = topValue as AnyObject
            FIRDatabase.database().reference().updateChildValues(fanoutObject)
            print("Buckets Joined")
        }
        
        let databaseRef = FIRDatabase.database().reference()
        var reading: NSDictionary = [:]
        // Query for the Top Dictionary (the one that has just been joined)
        let query = databaseRef.child("timeSegments").child((FIRAuth.auth()?.currentUser?.uid)!).queryOrdered(byChild: "upper").queryLimited(toLast: 1)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("We've got a problem")
            } else {
                let enumerator = snapshot.children
                var firstSnapshot: FIRDataSnapshot = FIRDataSnapshot()
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    reading = rest.value as! NSDictionary
                    print("reading: \(reading)")
                    firstSnapshot = rest
                }
                
                // Query for the one after that
                let query2 = databaseRef.child("timeSegments").child((FIRAuth.auth()?.currentUser?.uid)!).queryOrdered(byChild: "upper").queryLimited(toLast: 1).queryEnding(atValue: (reading["upper"] as! Double) - 0.001)
                query2.observeSingleEvent(of: .value, with: { (snapshot2) in
                    
                    if snapshot2.value is NSNull {
                        //"Only one bucket, reached the end"
                        print("No second segment")
                    } else {
                        let enumerator2 = snapshot2.children
                        var readingLower: NSDictionary = [:]
                        var secondSnapshot: FIRDataSnapshot = FIRDataSnapshot()
                        while let rest2 = enumerator2.nextObject() as? FIRDataSnapshot {
                            readingLower = rest2.value as! NSDictionary
                            secondSnapshot = rest2
                        }
                        
                        print("readingLower: \(readingLower)")
                        print("rest2: \(secondSnapshot)")
                        
                        /*if readingLower["upper"] as! Double == 0 {
                            //No more dresses
                            self.loadingLabel.text = "No More Items"
                        } else { */
                            //Make these are new segments
                            self.currentTimeSegment = (reading["upper"] as! Double, reading["lower"] as! Double)
                            self.currentTimeSegmentKey = firstSnapshot.key
                            self.nextTimeSegment = (readingLower["upper"] as! Double, readingLower["lower"] as! Double)
                            self.nextTimeSegmentKey = secondSnapshot.key
                            print("Getting New Segments!")
                            self.endOfSegment = false
                            self.catchNextDress(count: 1, time: self.currentTimeSegment.1, start: true)
                        //}
                    }
                })
            }
        })

    }
    
    //MARK: Swipe Actions
 
    func cardSwipedLeft(_ card: UIView) -> Void {
        loadedCards.remove(at: 0)

       /* if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }*/
        
        //Add reference of swiped dress to viewed dresses array and upload the new array to the server
        viewedDressReferences.append(dressReel[0].ref!)
        saveViewdDressRef()
        
        currentDressIndex = currentDressIndex + 1
        catchNextDress(count: 1, time: dressReel[0].timestamp, start: false)
        dressReel.remove(at: 0)
        
        /*
        if endOfSegment != true {
            currentTimeSegment.1 -= 1
            catchNextDress(count: 1)
        } else {
            if dressReel.count == 0 {
                print("In card swiped left")
                updateSegments(joining: true)
            }
        } */
        //toCome += 1
    }
    
    func cardSwipedRight(_ card: UIView) -> Void {
        
        loadedCards.remove(at: 0)
        
        //Add reference of swiped dress to saved dresses array and upload the new array to the server
        saveViewdDressRef()
        saveDressRef()
        
        currentDressIndex = currentDressIndex + 1
        catchNextDress(count: 1, time: dressReel[0].timestamp, start: false)
        dressReel.remove(at: 0)
        
        
        /*
        if endOfSegment != true {
            currentTimeSegment.1 -= 1
            catchNextDress(count: 1)
        } else {
            if dressReel.count == 0 {
                print("In card swiped left")
                updateSegments(joining: true)
            }
        } */
        //toCome += 1
    }

    func swipeRight() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: DraggableView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeRight)
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.rightClickAction()
    }

    func swipeLeft() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: DraggableView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeLeft)
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.leftClickAction()
    }
    
    func saveDressRef() {
        
        let databaseRef = FIRDatabase.database().reference()
        let userIdentifier = user?.uid
        
        var fanoutObject: [String: AnyObject] = [:]
        fanoutObject["/Users/\(userIdentifier!)/savedDresses/\(dressReel[0].ref!)"] = Int32(NSDate.timeIntervalSinceReferenceDate) as AnyObject
        fanoutObject["/PostData/\(dressReel[0].ref!)/swipedRight/\(userIdentifier!)"] = Int32(NSDate.timeIntervalSinceReferenceDate) as AnyObject
        
        if dressReel[0].timestamp > currentTimeSegment.1 {
            fanoutObject["/timeSegments/\(userIdentifier!)/\(currentTimeSegmentKey)/lower"] = dressReel[0].timestamp as AnyObject
            fanoutObject["/timeSegments/\(userIdentifier!)/\(currentTimeSegmentKey)/upper"] = currentTimeSegment.0 as AnyObject
        }
        
        databaseRef.updateChildValues(fanoutObject)
    }

    func saveViewdDressRef() {
        
        let databaseRef = FIRDatabase.database().reference()
        let userIdentifier = user?.uid
        
        var fanoutObject: [String: AnyObject] = [:]
        fanoutObject["/PostData/\(dressReel[0].ref!)/swipedLeft/\(userIdentifier!)"] = Int32(NSDate.timeIntervalSinceReferenceDate) as AnyObject
        
        if dressReel[0].timestamp > currentTimeSegment.1 {
            fanoutObject["/timeSegments/\(userIdentifier!)/\(currentTimeSegmentKey)/lower"] = dressReel[0].timestamp as AnyObject
            fanoutObject["/timeSegments/\(userIdentifier!)/\(currentTimeSegmentKey)/upper"] = currentTimeSegment.0 as AnyObject
        }
        
        databaseRef.updateChildValues(fanoutObject)
    }
    
    func displayReloadButton () {
        reloadButton = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 80, y: (UIScreen.main.bounds.height / 2) - 30, width: 160, height: 60))
        //reloadButton.isHidden = false
        reloadButton.backgroundColor = UIColor.blue
        reloadButton.tag = 174 //Just a random tag to then remove the button when its pressed
        self.addSubview(reloadButton)
        reloadButton.addTarget(self, action: #selector(DraggableViewBackground.reload), for: UIControlEvents.touchUpInside)
    }
    
    func reload() {
        
        dressReel = []
        loadedCards = []
        currentDressIndex = 0
        reloadButton.isHidden = true
    }
}

extension DraggableViewBackground: CardTapDelegate {
    func cardHasBeenTappedOn(sender: UITapGestureRecognizer) {
        print("Trying from background")
        delegate3?.didTapPhoto(sender: sender)
    }
}

protocol TapDelegate3: class {
    func didTapPhoto(sender: UITapGestureRecognizer)
}
