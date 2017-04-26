//
//  ChatViewController.swift
//  SPIN
//
//  Created by Pelayo Martinez on 22/12/2016.
//  Copyright © 2016 Pelayo Martinez. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import Photos
import OneSignal

private let reuseIdentifier = "cell"

class ChatViewController: JSQMessagesViewController {
    
    var refToLoad: String = ""
    var name: String = ""
    var photoURL: String = ""
    var messages = [JSQMessage]()
    var uid: String = "" {
        didSet {
            print("Set to \(uid)")
            getNotificationID()
        }
    }
    var notificationKey: String = ""
    var toUpload: Bool = false
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    private let imageURLNotSetKey = "NOTSET"
    var storageRef: FIRStorageReference = FIRStorage.storage().reference()
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var updatedMessageRefHandle: FIRDatabaseHandle?
    private var newMessageRefHandle: FIRDatabaseHandle?
    private var userIsTypingRef: FIRDatabaseReference = FIRDatabase.database().reference()
    
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    
    private lazy var messageRef: FIRDatabaseReference = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageRef = FIRDatabase.database().reference().child("Conversations").child(refToLoad)
        userIsTypingRef = FIRDatabase.database().reference().child("Conversations").child(refToLoad).child("typingIndicator").child(self.senderId)
        
        let image3: UIImage = #imageLiteral(resourceName: "addImage")
        let button3: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button3.setImage( image3, for: .normal)
        button3.addTarget(self, action: #selector(options), for: .touchUpInside)
        
        let barButton3 = UIBarButtonItem(customView: button3)
        self.navigationItem.rightBarButtonItem = barButton3
        
        self.navigationController?.navigationBar.topItem?.title = " "
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
            self.navigationItem.title = self.name
        }, completion: nil)
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        observeMessages()
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    func options() {
        let alert = UIAlertController(title: "More", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { action in
            
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("sendReport")
                
                let reference = FIRDatabase.database().reference().child("Users").child( (FIRAuth.auth()?.currentUser?.uid)! ).child("conversations").child(self.refToLoad).child("blocked")
                
                reference.setValue("true")
                
                let transition = CATransition()
                transition.duration = 0.2
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.navigationController?.dismiss(animated: false, completion: nil)
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
            switch action.style{
            case .cancel:
                print("cancel")
            default: break
                
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    
    func getNotificationID() {
        FIRDatabase.database().reference().child("OneSignalIDs").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                //No notification key found
                print("The person can't receive notifications")
            } else {
                self.notificationKey = snapshot.value! as! String
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let unseenRef = FIRDatabase.database().reference().child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("conversations").child(refToLoad).child("unseen")
        unseenRef.setValue(0)
        
        if toUpload == false {
            BadgeHandler.messages[uid] = 0
        } else {
            toUpload = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let unseenRef = FIRDatabase.database().reference().child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("conversations").child(refToLoad).child("unseen")
        unseenRef.setValue(0)
        BadgeHandler.messages[uid] = 0
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        print(1)
        
        let itemRef = messageRef.child("messages").childByAutoId()
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!]
        
        print(2)
        
        itemRef.setValue(messageItem)
        messageRef.child("timestamp").setValue((NSDate().timeIntervalSince1970) as NSNumber)
        print(3)
        let unseenRef = FIRDatabase.database().reference().child("Users").child(uid).child("conversations").child(refToLoad).child("unseen")
        unseenRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { } else {
                var counter = (snapshot.value)! as! Int
                counter += 1
                unseenRef.setValue(counter)
            }
        })
        print(4)
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let pushToken = status.subscriptionStatus.pushToken
        _ = status.subscriptionStatus.userId
        print(5)
        if pushToken != nil {
            let message = text!
            let notificationContent = [
                "include_player_ids": [notificationKey],
                "contents": ["en": "\(senderDisplayName!): \(message)"],
                
                "data": ["senderUid": (senderId)],
                // If want to open a url with in-app browser
                //"url": "https://google.com",
                // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
                "ios_badgeType": "Increase",
                "ios_badgeCount": 1
                ] as [String : Any]
            print(notificationKey)
            OneSignal.postNotification(notificationContent)
        }
        
        
        
        
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
        isTyping = false
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        toUpload = true
        
        present(picker, animated: true, completion:nil)
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func observeMessages() {
        
        let messageQuery = messageRef.child("messages").queryLimited(toLast:25)
        
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            let messageData = snapshot.value as! [String: String]
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                
                self.addMessage(withId: id, name: name, text: text)
                
                self.finishReceivingMessage()
                
            } else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.child("messages").observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
        
    }
  
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
 
    private func observeTyping() {
        
        let usersAreTypingRef = FIRDatabase.database().reference().child("Conversations").child(refToLoad).child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
        
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersAreTypingRef.observe(.value, with: { (snapshot) in
            
            if snapshot.childrenCount == 1 && self.isTyping {
                self.showTypingIndicator = false
                return
            }
            
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottom(animated: true)
        })
    }

    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.child("messages").childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child("messages").child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        
        
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                
                if (metadata?.contentType == "image/gif") {
                    //mediaItem.image = UIImage.gifWithData(data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
}






// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            if let key = sendPhotoMessage() {
                
                let uploadMetadata = FIRStorageMetadata()
                uploadMetadata.contentType = "image/jpeg"
                let imageData = UIImageJPEGRepresentation(possibleImage, 8)

                let newRef = storageRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("imageMessages").child("\(Int(Date.timeIntervalSinceReferenceDate * 1000))")
                    
                    newRef.put(imageData!, metadata: uploadMetadata, completion: {
                    (metadata, error) in
                    if(error != nil) {
                        print("I received an error! \(String(describing: error?.localizedDescription))")
                    }
                    else{
                        print("Upload Complete! Here's some metadata \(String(describing: metadata))")
                        self.setImageURL(newRef.description, forPhotoMessageWithKey: key)
                    }
                })
                
            dismiss(animated: true, completion: nil)
        }
        else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                
                if let key = sendPhotoMessage() {
                    
                    let uploadMetadata = FIRStorageMetadata()
                    uploadMetadata.contentType = "image/jpeg"
                    let imageData = UIImageJPEGRepresentation(possibleImage, 8)
                    
                    let newRef = storageRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("imageMessages").child("\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg")
                    
                    newRef.put(imageData!, metadata: uploadMetadata, completion: {
                        (metadata, error) in
                        if(error != nil) {
                            print("I received an error! \(String(describing: error?.localizedDescription))")
                        }
                        else{
                            print("Upload Complete! Here's some metadata \(String(describing: metadata))")
                            self.setImageURL(newRef.description, forPhotoMessageWithKey: key)
                        }
                    })
                    dismiss(animated: true, completion: nil)
                } else {
                    dismiss(animated: true, completion: nil) }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}
