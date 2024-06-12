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

class ConversationsTableViewController: UITableViewController {
    let serviceManager : ServicesManager
    let conversationsManager : ConversationsManagerService
    var selectedIndex : IndexPath? = nil
    var allConversations : [Conversation] = []
    var populated = false
    
    required init?(coder aDecoder: NSCoder) {
        serviceManager = ServicesManager.sharedInstance()
         conversationsManager = serviceManager.conversationsManagerService
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector:#selector(didReceiveNewMessageForConversation(notification:)), name:NSNotification.Name(kConversationsManagerDidReceiveNewMessageForConversation), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didAddConversation(notification:)), name:NSNotification.Name(kConversationsManagerDidAddConversation), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRemoveConversation(notification:)), name:NSNotification.Name(kConversationsManagerDidRemoveConversation), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateConversation(notification:)), name:NSNotification.Name(kConversationsManagerDidUpdateConversation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateMessagesUnreadCount(notification:)), name:NSNotification.Name(kConversationsManagerDidUpdateMessagesUnreadCount), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndLoadingConversations), name: NSNotification.Name( kConversationsManagerDidEndLoadingConversations), object: nil)
        
        // notification sent when the app regain the network after loosing it
        NotificationCenter.default.addObserver(self, selector: #selector(didReconnect(notification:)), name: NSNotification.Name(kLoginManagerDidReconnect), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRightButton()
        self.tableView.reloadData()
    }
    
    func configureRightButton() {
        let logout = UIAction(title: "Logout", image: UIImage(systemName: "power.circle")) { _ in
            ServicesManager.sharedInstance().loginManager.disconnect()
            ServicesManager.sharedInstance().loginManager.resetAllCredentials()
            self.dismiss(animated: false, completion: nil)
        }
        
        let menu = UIMenu(title: "", children: [logout])
        let barButton = UIBarButtonItem(title: "", image: UIImage(systemName: "ellipsis"), menu: menu)
        navigationItem.rightBarButtonItem = barButton
    }

    @IBAction func logoutAction(_ sender: Any) {
        ServicesManager.sharedInstance().loginManager.disconnect()
        ServicesManager.sharedInstance().loginManager.resetAllCredentials()
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Notifications related to unread conversation count
    
    @objc func didUpdateMessagesUnreadCount(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.updateBadgeValue()
                self.tableView .reloadData()
            }
        }
    }

    // MARK: - Notifications related to losing/recovering network
    
    @objc func didReconnect(notification : NSNotification) {
        NSLog("[ConversationsTableViewController] Did reconnect")
    }
    
    // MARK: - conversation notifications
    
    @objc func didReceiveNewMessageForConversation(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didReceiveNewMessageForConversation(notification: notification)
            }
            return
        }
        self.sortAllConversation()
        
    }
    
    @objc func didAddConversation(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didAddConversation(notification: notification)
            }
            return
        }
        let theConversation = notification.object as! Conversation
        if (theConversation.conversationId != nil) {
            if (allConversations.firstIndex(of: theConversation) == nil) {
                allConversations.append(theConversation)
            }
        }
        self.sortAllConversation()
    }
    
    @objc func didUpdateConversation(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didUpdateConversation(notification: notification)
            }
            return
        }
       self.sortAllConversation()
    }
    
    @objc func didRemoveConversation(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didRemoveConversation(notification: notification)
            }
            return
        }
        let theConversation = notification.object as! Conversation
        if let index = allConversations.firstIndex(of: theConversation) {
            if (index != NSNotFound) {
                allConversations.remove(at: index)
            }
        }
        self.sortAllConversation()
    }
    
    
    @objc func didEndLoadingConversations() {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didEndLoadingConversations()
            }
            return
        }
        
        self.loadAllConversations()
        self.sortAllConversation()
        self.updateBadgeValue()
        populated = true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allConversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationsTableViewCell", for: indexPath)
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let conversationsCell = cell as? ConversationsTableViewCell {
            if let lastMessage = allConversations[indexPath.row].lastMessage {
                conversationsCell.lastMessage.text = lastMessage.body
            } else {
                conversationsCell.lastMessage.text = ""
            }
            
            if let contact = allConversations[indexPath.row].peer as? Contact {
                // The peer is a Contact, the conversation is one to one
                if let photoData = contact.photoData {
                    conversationsCell.avatar.image = UIImage(data: photoData)
                    conversationsCell.avatar.tintColor = UIColor.clear
                } else {
                    conversationsCell.avatar.image = UIImage(named: "Default_Avatar")
                    conversationsCell.avatar.tintColor = UIColor(hue:CGFloat(indexPath.row*36%100)/100.0, saturation:1.0, brightness:1.0, alpha:1.0)
                }
                
                conversationsCell.peerName.text = contact.fullName
                
            } else if let room = allConversations[indexPath.row].peer as? Room {
                // The peer is a Room, the conversation is a chat room
                conversationsCell.avatar.image = UIImage(named: "Default_Room_Avatar")
                conversationsCell.avatar.tintColor = UIColor(hue:CGFloat(indexPath.row*36%100)/100.0, saturation:1.0, brightness:1.0, alpha:1.0)
                conversationsCell.peerName.text = room.displayName
            }
            
            if(allConversations[indexPath.row].unreadMessagesCount != 0) {
                conversationsCell.badgeValue.isHidden = false
                conversationsCell.badgeValue.text = "\(allConversations[indexPath.row].unreadMessagesCount)"
            } else {
                conversationsCell.badgeValue.isHidden = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        let conversation = allConversations[indexPath.row]
        conversationsManager.markAllMessagesAsRead(for: conversation)
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ChatWithSegue", sender: self)
    }
    
    override func tableView(_ tableView : UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let swipeActions = UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .normal, title: "Close", handler: { _,_,_ in
                let conversation = self.allConversations[indexPath.row]
                self.conversationsManager.stopConversation(conversation)
            })
        ])
        
        return swipeActions
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatWithSegue" {
            if let selectedIndex = selectedIndex {
                if let vc = segue.destination as? ChatViewController {
                    let peer = allConversations[selectedIndex.row].peer
                    vc.conversationPeer = try! ConversationPeer(peer)
                    vc.contactImage = (tableView.cellForRow(at: selectedIndex) as? ConversationsTableViewCell)?.avatar.image
                    vc.contactImageTint = (tableView.cellForRow(at: selectedIndex) as? ConversationsTableViewCell)?.avatar.tintColor
                }
            }
        }
    }

    func loadAllConversations() {
        allConversations = []
        for conversation in conversationsManager.conversations {
            allConversations.append(conversation)
        }
       
    }
    
    func sortAllConversation() {
        allConversations.sort{($0.lastUpdateDate ?? .distantPast) > ($1.lastUpdateDate ?? .distantPast)}
        self.tableView.reloadData()
    }
    
    func updateBadgeValue() {
        let totalNbOfUnreadMessagesInAllConversations = ServicesManager.sharedInstance().conversationsManagerService.totalNbOfUnreadMessagesInAllConversations
        if(totalNbOfUnreadMessagesInAllConversations == 0) {
            tabBarController?.tabBar.items?[0].badgeValue  = nil;
        }
        else {
            tabBarController?.tabBar.items?[0].badgeValue = "\(totalNbOfUnreadMessagesInAllConversations)"
        }
    }
}
