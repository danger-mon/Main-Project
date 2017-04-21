//
//  DraggableView.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

let ACTION_MARGIN: Float = 100      //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
let SCALE_STRENGTH: Float = 4       //%%% how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX:Float = 0.93          //%%% upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX: Float = 1         //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH: Float = 320  //%%% strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE: Float = 3.14/8  //%%% Higher = stronger rotation angle
let CARD_HEIGHT: CGFloat = UIScreen.main.bounds.width - 10
let CARD_WIDTH: CGFloat = UIScreen.main.bounds.width - 10
let CARD_X: CGFloat = (UIScreen.main.bounds.width - CARD_WIDTH) / 2
let CARD_Y: CGFloat = (UIScreen.main.bounds.height - CARD_HEIGHT) / 2


protocol DraggableViewDelegate {
    func cardSwipedLeft(_ card: UIView) -> Void
    func cardSwipedRight(_ card: UIView) -> Void
}

class DraggableView: UIView {
    var delegate: DraggableViewDelegate!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var originPoint: CGPoint!
    var overlayView: OverlayView!
    var information: UILabel!
    var xFromCenter: Float!
    var yFromCenter: Float!
    var dressImageView: UIImageView!
    //var dressImage: UIImage!
    var reference: String!
    var containerView: UIView!
    weak var tapDelegate: CardTapDelegate?
    
    var dressName: UILabel!
    var dressDescription: UITextView!
    var profileView: MiniProfile!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        
        //containerView = UIView(frame: CGRect(x: 0, y: CARD_Y, width: CARD_WIDTH, height: CARD_HEIGHT))
        //containerView.bounds = CGRect(x: 0, y: 0, width: CARD_WIDTH + 5, height: CARD_HEIGHT + 100)
        //containerView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1)
        //containerView = UIImageView(image: #imageLiteral(resourceName: "loading"))
        //containerView.bounds = CGRect(x: 0, y: 0, width: CARD_WIDTH, height: CARD_HEIGHT)
        
        self.isUserInteractionEnabled = true
        
        self.bounds = CGRect(x: 0, y: 0, width: CARD_WIDTH, height: CARD_HEIGHT + 150)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        /*self.layer.shadowColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1).cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 0) */
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        
        information = UILabel(frame: CGRect(x: 0, y: 40, width: self.frame.size.width, height: 200))
        information.text = "no info given"
        information.textAlignment = NSTextAlignment.left
        information.textColor = UIColor.black
        information.lineBreakMode = .byWordWrapping
        
        dressImageView = UIImageView(image: #imageLiteral(resourceName: "placeholderImage"))
        dressImageView.contentMode = .scaleAspectFill
        dressImageView.frame = CGRect(x: 0, y: 40 + 4 + 4, width: CARD_WIDTH, height: CARD_WIDTH)
        dressImageView.clipsToBounds = true
        self.addSubview(dressImageView!)
        
        //dressName = UILabel(frame: CGRect(x: 23 , y: 3/2*CARD_HEIGHT - 34 , width: CARD_WIDTH, height: 50))
        dressName = UILabel(frame: CGRect(x: 10 , y: CARD_HEIGHT + 40 + 4, width: CARD_WIDTH, height: 50))
        dressName.text = "" //.uppercased()
        dressName.textColor = UIColor.black
        dressName.textAlignment = .left
        dressName.font = UIFont(name: "Avenir", size: 18.0)
        self.addSubview(dressName)
        
        //Creates a label for the dress description
        //dressDescription = UITextView(frame: CGRect(x: 19 , y: 3/2*CARD_HEIGHT - 5 , width: CARD_WIDTH, height: 100))
        dressDescription = UITextView(frame: CGRect(x: 6 , y: CARD_HEIGHT + 40 + 30 + 4, width: CARD_WIDTH, height: 100))
        dressDescription.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0)
        dressDescription.text = ""
        dressDescription.textColor = UIColor.darkGray
        dressDescription.font = UIFont(name: "Avenir", size: 10.0)
        dressDescription.textAlignment = .left
        dressDescription.allowsEditingTextAttributes = false
        dressDescription.isEditable = false
        self.addSubview(dressDescription)
        
        //Creates the profile display
        profileView = MiniProfile()
        let profileViewRect = profileView.bounds
        profileView.bounds = CGRect(x: profileViewRect.origin.x - 3, y: profileViewRect.origin.y - 5, width: profileViewRect.width, height: profileViewRect.height)
        self.addSubview(profileView)
        //containerView.sizeToFit()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        self.addGestureRecognizer(tap)
        
        //self.addSubview(containerView)

        //self.backgroundColor = UIColor.blue
        self.layer.cornerRadius = 2

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DraggableView.beingDragged(_:)))

        self.addGestureRecognizer(panGestureRecognizer)
        //self.addSubview(information)

        overlayView = OverlayView(frame: CGRect(x: self.frame.size.width/2-100, y: 0, width: 100, height: 100))
        overlayView.alpha = 1
        self.addSubview(overlayView)
        updateOverlay(0)

        xFromCenter = 0
        yFromCenter = 0
    }
    
    func getOwnImage() {
        let pathReference = FIRStorage.storage().reference(withPath: "dressImages/\(reference!)/1.jpg")
        _ = pathReference.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print(error!)
            } else {
                self.dressImageView.image = UIImage(data: data!)
            }
        })

    }
    
    func cardTapped(sender: UITapGestureRecognizer)
    {
        print("Thsi one works")
        print(tapDelegate.debugDescription)
        tapDelegate?.cardHasBeenTappedOn(sender: sender)
    }

    func setupView() -> Void {
        self.layer.cornerRadius = 4;
        self.backgroundColor = UIColor.blue
        //self.layer.shadowRadius = 3;
        //self.layer.shadowOpacity = 0.1;
        //self.layer.shadowOffset = CGSize(width: 1, height: 1);
    }

    func beingDragged(_ gestureRecognizer: UIPanGestureRecognizer) -> Void {
        xFromCenter = Float(gestureRecognizer.translation(in: self).x)
        yFromCenter = Float(gestureRecognizer.translation(in: self).y)
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.began:
            self.originPoint = self.center
        case UIGestureRecognizerState.changed:
            let rotationStrength: Float = min(xFromCenter/ROTATION_STRENGTH, ROTATION_MAX)
            let rotationAngle = ROTATION_ANGLE * rotationStrength
            let scale = max(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)

            self.center = CGPoint(x: self.originPoint.x + CGFloat(xFromCenter), y: self.originPoint.y + CGFloat(yFromCenter))

            let transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
            let scaleTransform = transform.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
            self.transform = scaleTransform
            self.updateOverlay(CGFloat(xFromCenter))
        case UIGestureRecognizerState.ended:
            self.afterSwipeAction()
        case UIGestureRecognizerState.possible:
            fallthrough
        case UIGestureRecognizerState.cancelled:
            fallthrough
        case UIGestureRecognizerState.failed:
            fallthrough
        default:
            break
        }
    }

    func updateOverlay(_ distance: CGFloat) -> Void {
        if distance > 0 {
            overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeRight)
        } else {
            overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeLeft)
        }
        overlayView.alpha = CGFloat(min(fabsf(Float(distance))/100, 0.6))
    }

    func afterSwipeAction() -> Void {
        let floatXFromCenter = Float(xFromCenter)
        if floatXFromCenter > ACTION_MARGIN {
            self.rightAction()
        } else if floatXFromCenter < -ACTION_MARGIN {
            self.leftAction()
        } else {
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                self.center = self.originPoint
                self.transform = CGAffineTransform(rotationAngle: 0)
                self.overlayView.alpha = 0
            })
        }
    }
    
    func rightAction() -> Void {
        let finishPoint: CGPoint = CGPoint(x: 500, y: 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animate(withDuration: 0.3,
            animations: {
                self.center = finishPoint
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedRight(self)
    }

    func leftAction() -> Void {
        let finishPoint: CGPoint = CGPoint(x: -500, y: 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animate(withDuration: 0.3,
            animations: {
                self.center = finishPoint
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedLeft(self)
    }

    func rightClickAction() -> Void {
        let finishPoint = CGPoint(x: 600, y: self.center.y)
        UIView.animate(withDuration: 0.3,
            animations: {
                self.center = finishPoint
                self.transform = CGAffineTransform(rotationAngle: 1)
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedRight(self)
    }

    func leftClickAction() -> Void {
        let finishPoint: CGPoint = CGPoint(x: -600, y: self.center.y)
        UIView.animate(withDuration: 0.3,
            animations: {
                self.center = finishPoint
                self.transform = CGAffineTransform(rotationAngle: 1)
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedLeft(self)
    }
}

protocol CardTapDelegate: class {
    func cardHasBeenTappedOn(sender: UITapGestureRecognizer)
}
