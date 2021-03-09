/*
 * Rainbow SDK sample
 *
 * Copyright (c) 2018, ALE International
 * All rights reserved.
 *
 * ALE International Proprietary Information
 *
 * Contains proprietary/trade secret information which is the property of
 * ALE International and must not be made available to, or copied or used by
 * anyone outside ALE International without its written authorization
 *
 * Not to be disclosed or used except in accordance with applicable agreements.
 */

import UIKit
import Rainbow

extension NSObject {
    func synchronized<T>(_ lockObj: AnyObject!, closure: () throws -> T) rethrows ->  T {
        objc_sync_enter(lockObj)
        defer {
            objc_sync_exit(lockObj)
        }
        return try closure()
    }
}

// Swift equivalent of removeObjectsAtIndexes
extension Array {
    mutating func remove(indices: IndexSet) {
        self = self.enumerated().filter { !indices.contains($0.offset) }.map { $0.element }
    }
}

class MessageItem : NSObject {
    var peer : Peer?
    var text : String?
    var date : Date?
}

class ChatViewController: UIViewController, UITextViewDelegate, CKItemsBrowserDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var peer : Peer?
    var contactImage : UIImage?
    var contactImageTint : UIColor?
    
    @IBOutlet fileprivate weak var messageList: UITableView!
    @IBOutlet fileprivate weak var textInput: UITextView!
    @IBOutlet fileprivate weak var sendButton: UIButton!
    @IBOutlet weak var loadMoreButton: UIBarButtonItem!
    
    fileprivate let kPageSize = 10
    fileprivate let serviceManager : ServicesManager
    fileprivate let conversationsManager : ConversationsManagerService
    fileprivate var messagesBrowser : MessagesBrowser?
    fileprivate var messages : [MessageItem] = []
    fileprivate var myAvatar : UIImage?
    fileprivate var peerAvatar : UIImage?
    fileprivate var theConversation : Conversation?
    
    required init?(coder aDecoder: NSCoder) {
        serviceManager = ServicesManager.sharedInstance()
        conversationsManager = serviceManager.conversationsManagerService
        super.init(coder: aDecoder)
        if let contact =  serviceManager.myUser.contact, contact.photoData != nil {
            myAvatar = UIImage(data: contact.photoData)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textInput.delegate = self
        self.title = "Conversations"
        if let contact = peer as? Contact, let photoData = contact.photoData {
            peerAvatar = UIImage(data: photoData)
        }
        
        // All conversations for myUser
        for conversation in conversationsManager.conversations {
            if conversation.peer == peer {
                theConversation = conversation
                break
            }
        }
        
        // If there is no conversation with this peer, create a new one
        if (theConversation != nil) {
            if ((theConversation?.peer.displayName) != nil) {
                self.title = theConversation?.peer.displayName;
            }
            conversationsManager.startConversation(with: peer){ (conversation : Optional<Conversation>, error : Optional<Error>)  in
                if error != nil {
                    self.theConversation = conversation
                } else {
                    NSLog("Can't create the new conversation, error: \(error.debugDescription)")
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(notification:)), name:NSNotification.Name("UIKeyboardWillShowNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardDidHide(notification:)),
            name:NSNotification.Name("UIKeyboardDidHideNotification"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didReceiveNewMessage(notification:)), name:NSNotification.Name(kConversationsManagerDidReceiveNewMessageForConversation), object:nil)
        
        loadMoreButton.isEnabled = false
        messagesBrowser = conversationsManager.messagesBrowser(for: self.theConversation, withPageSize:kPageSize, preloadMessages:true)
        messagesBrowser?.delegate = self
        messagesBrowser?.resyncBrowsingCache { (addedCacheItems : Optional<Array<Any>>, removedCacheItems : Optional<Array<Any>>, updatedCacheItems : Optional<Array<Any>>, error : Optional<Error>) in
            NSLog("Resync done")
            let hasPage = self.messagesBrowser?.hasMorePages() ?? false
            self.loadMoreButton.isEnabled = hasPage
        }
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    // Scroll the message list to the latest one when the reloadData has finished
    func reloadAndScrollToBottom() {
        if self.messageList.dataSource == nil {
            // ChatViewController is being deallocated
            return
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock(){
            if self.messageList.numberOfRows(inSection: 0) > 0 {
                let lastRow = IndexPath(item: self.messageList.numberOfRows(inSection: 0) - 1, section:0)
                self.messageList.scrollToRow(at: lastRow, at:.bottom, animated:true)
            }
            
        }
        self.messageList.reloadData()
        CATransaction.commit()
    }

    
    // MARK: - IBAction
    
    @IBAction func sendAction(_ sender : AnyObject) {
        if let theConversation = theConversation {
            sendButton.isEnabled = false
            textInput.isEditable = false
            conversationsManager.sendTextMessage(textInput.text, files: nil, mentions: nil, priority: .default, repliedMessage: nil, conversation: theConversation) { (message, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        self.textInput.text = ""
                    } else {
                        NSLog("Can't send message to the conversation error: \(error.debugDescription)")
                        self.sendButton.isEnabled = true
                    }
                    self.textInput.isEditable = true
                }
            }
        }
    }
    
    @IBAction func loadMoreAction(_ sender: Any) {
        self.loadMoreButton.isEnabled = false
        messagesBrowser?.nextPage() { (addedCacheItems, removedCacheItems, updatedCacheItems, error) in
            if let error = error {
                NSLog("Error while loading next page: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    let hasPage = self.messagesBrowser?.hasMorePages() ?? false
                    self.loadMoreButton.isEnabled = hasPage
                }
            }
        }
    }
    
    // MARK: - CKItemsBrowserDelegate
    
    func itemsBrowser(_ browser: CKItemsBrowser!, didAddCacheItems newItems: [Any]!, at indexes: IndexSet!) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.itemsBrowser(browser, didAddCacheItems:newItems, at:indexes)
            }
            return
        }

        NSLog("CKItemsBrowser didAddCacheItems")
        synchronized(self.messages as AnyObject){
            // insert new items at the beginning of the messages array
            for (index, _) in indexes.sorted().enumerated() {
                if let message = newItems[index] as? Message {
                    let item = MessageItem()
                    if message.isOutgoing {
                        item.peer = self.serviceManager.myUser.contact
                    } else {
                        item.peer = message.peer
                    }
                    item.text = message.body
                    item.date = message.date
                    self.messages.insert(item, at: index)
                    self.messages.sort{($0.date ?? .distantPast) > ($1.date ?? .distantPast)}

                }
            }
        }
        reloadAndScrollToBottom()
    }

    func itemsBrowser(_ browser: CKItemsBrowser!, didRemoveCacheItems removedItems: [Any]!, at indexes: IndexSet!) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.itemsBrowser(browser, didRemoveCacheItems:removedItems, at:indexes)
            }
            return
        }
        
        NSLog("CKItemsBrowser didRemoveCacheItems")
        synchronized(self.messages as AnyObject){
            let validatedIndexes = IndexSet(indexes.filter({ $0 < self.messages.count }))
            self.messages.remove(indices: validatedIndexes)
        }
        reloadAndScrollToBottom()
    }
    
    func itemsBrowser(_ browser: CKItemsBrowser!, didUpdateCacheItems changedItems: [Any]!, at indexes: IndexSet!) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.itemsBrowser(browser, didUpdateCacheItems:changedItems, at:indexes)
            }
            return
        }
        
        NSLog("CKItemsBrowser didUpdateCacheItems")
        reloadAndScrollToBottom()
    }
    
    func itemsBrowser(_ browser: CKItemsBrowser!, didReorderCacheItemsAtIndexes oldIndexes: [Any]!, toIndexes newIndexes: [Any]!) {
        NSLog("CKItemsBrowser didReorderCacheItemsAtIndexes")
    }
    
    // MARK: - UITextviewDelegate
    
    func textViewDidChange(_ textView : UITextView) {
        sendButton.isEnabled = textView.text.count > 0 ? true : false
    }
    
    // MARK: - Conversation manager notification
    
    @objc func didReceiveNewMessage(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didReceiveNewMessage(notification: notification)
            }
            return
        }
        if let receivedConversation = notification.object as? Conversation {
            if receivedConversation == self.theConversation, let conversation = self.theConversation {
                NSLog("did received new message for the conversation")
                self.conversationsManager.markAllMessagesAsRead(for: conversation)
                let lastRow = IndexPath(row:  messageList.numberOfRows(inSection: 0) - 1, section: 0)
                messageList.scrollToRow(at: lastRow, at: .bottom, animated: true)
                messageList.reloadData()
            }
        }
    }
    
    // MARK: - Keyboard notification
    
    @objc func keyboardWillShow(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.keyboardWillShow(notification: notification)
            }
            return
        }
        UIView.beginAnimations(nil, context:nil)
        if let userInfo = notification.userInfo as? [String: Any] {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                self.view.frame = CGRect(x: 0,  y: -keyboardRectangle.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
                UIView.commitAnimations()
            }
        }
    }
    
    @objc func keyboardDidHide(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.keyboardDidHide(notification : notification)
            }
            return
        }
        UIView.beginAnimations(nil, context:nil)
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        UIView.commitAnimations()
    }

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.messages.count - indexPath.row - 1
        if self.messages[row].peer == serviceManager.myUser.contact {
            return tableView.dequeueReusableCell(withIdentifier: "MyUserTableViewCell", for:indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier:"PeerTableViewCell", for:indexPath)
        }
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = self.messages.count - indexPath.row - 1
        if let myCell = cell as? MyUserTableViewCell {
            if myAvatar != nil {
                myCell.avatar.image = myAvatar
            }
            if (messages[row].text != nil) {
                myCell.message.text = messages[row].text
            }
        } else if let peerCell = cell as? PeerTableViewCell {
            if self.peerAvatar != nil {
                peerCell.avatar.image = peerAvatar
            }
            if (messages[row].text != nil) {
                peerCell.message.text = messages[row].text
            }
        }
    }
    
}
