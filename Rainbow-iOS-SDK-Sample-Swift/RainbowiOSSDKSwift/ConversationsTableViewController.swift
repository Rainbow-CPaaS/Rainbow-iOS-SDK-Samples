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
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        serviceManager = ServicesManager.sharedInstance()
         conversationsManager = serviceManager.conversationsManagerService
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector:#selector(didReceiveNewMessageForConversation(notification:)), name:NSNotification.Name(kConversationsManagerDidReceiveNewMessageForConversation), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didAddConversation(notification:)), name:NSNotification.Name(kConversationsManagerDidAddConversation), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRemoveConversation(notification:)), name:NSNotification.Name(kConversationsManagerDidRemoveConversation), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateConversation(notification:)), name:NSNotification.Name(kConversationsManagerDidUpdateConversation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateMessagesUnreadCount(notification:)), name:NSNotification.Name(kConversationsManagerDidUpdateMessagesUnreadCount), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidReceiveNewMessageForConversation), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidAddConversation), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidRemoveConversation), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidUpdateConversation), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidUpdateMessagesUnreadCount), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        allConversations = []
        self.loadAllConversations()
        self.sortAllConversation()
    }

    @IBAction func logoutAction(_ sender: Any) {
        ServicesManager.sharedInstance()?.loginManager.disconnect()
        ServicesManager.sharedInstance().loginManager.resetAllCredentials()
        self.dismiss(animated: false, completion: nil)
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
            if (allConversations.index(of: theConversation) == nil) {
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
        if let index = allConversations.index(of: theConversation) {
            if (index != NSNotFound) {
                allConversations.remove(at: index)
            }
        }
        self.sortAllConversation()
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
            if let photoData = (allConversations[indexPath.row].peer as? Contact)?.photoData {
                conversationsCell.avatar.image = UIImage(data: photoData)
                conversationsCell.avatar.tintColor = UIColor.clear
            } else {
                conversationsCell.avatar.image = UIImage(named: "Default_Avatar")
                conversationsCell.avatar.tintColor = UIColor(hue:CGFloat(indexPath.row*36%100)/100.0, saturation:1.0, brightness:1.0, alpha:1.0)
            }
            
            let contact = allConversations[indexPath.row].peer as? Contact
            conversationsCell.peerName.text = contact?.fullName
            
            if(allConversations[indexPath.row].unreadMessagesCount != 0) {
                conversationsCell.badgeValue.isHidden = false
                conversationsCell.badgeValue.text = "\(allConversations[indexPath.row].unreadMessagesCount)"
            }
            else {
                conversationsCell.badgeValue.isHidden = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        let conversation = allConversations[indexPath.row]
        conversationsManager.sendMarkAllMessagesAsRead(from: conversation)
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ChatWithSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatWithSegue" {
            if let selectedIndex = selectedIndex {
                if let vc = segue.destination as? ChatViewController {
                    if let contact = allConversations[selectedIndex.row].peer as? Contact {
                        vc.contact = contact
                    }
                    vc.contactImage = (tableView.cellForRow(at: selectedIndex) as? ConversationsTableViewCell)?.avatar.image
                    vc.contactImageTint = (tableView.cellForRow(at: selectedIndex) as? ConversationsTableViewCell)?.avatar.tintColor
                }
            }
        }
    }
    @objc func didUpdateMessagesUnreadCount(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                var totalNbOfUnreadMessagesInAllConversations = 0
                totalNbOfUnreadMessagesInAllConversations = ServicesManager.sharedInstance()?.conversationsManagerService.totalNbOfUnreadMessagesInAllConversations ?? 0
                if(totalNbOfUnreadMessagesInAllConversations == 0) {
                    self.tabBarController?.tabBar.items?[0].badgeValue  = nil;
                }
                else {
                    self.tabBarController?.tabBar.items?[0].badgeValue = "\(totalNbOfUnreadMessagesInAllConversations)"
                }
                self.tableView .reloadData()
            }
        }
        
    }

    func loadAllConversations() {
        for conversation in conversationsManager.conversations {
            if(conversation.peer != nil) {
                allConversations.append(conversation)
            }
        }
       
    }
    func sortAllConversation() {
        allConversations.sort{($0.lastUpdateDate ?? .distantPast) > ($1.lastUpdateDate ?? .distantPast)}
        self.tableView.reloadData()
    }
}
