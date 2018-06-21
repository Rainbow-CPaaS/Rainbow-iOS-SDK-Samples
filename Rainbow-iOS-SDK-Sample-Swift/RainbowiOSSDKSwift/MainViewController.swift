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

class MainViewController: UIViewController {
    @IBOutlet weak var contactsButton: UIButton!
    @IBOutlet weak var conversationsButton: UIButton!
    @IBOutlet weak var unreadMessagesCountLabel: UILabel!
    
    var reconnecting = false
    
    var totalNbOfUnreadMessagesInAllConversations = 0
    var conversationsLoaded = false
    var contactsLoaded = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // notifications related to the LoginManager
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin(notification:)), name: NSNotification.Name(kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReconnect(notification:)), name: NSNotification.Name(kLoginManagerDidReconnect), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout(notification:)), name: NSNotification.Name(kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToAuthenticate(notification:)), name: NSNotification.Name(kLoginManagerDidFailedToAuthenticate), object: nil)
        
        // notification related to the ContactManagerService
        NotificationCenter.default.addObserver(self, selector: #selector(didEndPopulatingMyNetwork(notification:)), name: NSNotification.Name(kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
        
        // notifications related to unread conversation count
        NotificationCenter.default.addObserver(self, selector: #selector(didEndLoadingConversations(notification:)), name:NSNotification.Name(kConversationsManagerDidEndLoadingConversations), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateMessagesUnreadCount(notification:)), name:NSNotification.Name(kConversationsManagerDidUpdateMessagesUnreadCount), object: nil)
    }
    
    deinit {
        // notifications related to the LoginManager
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidReconnect), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidFailedToAuthenticate), object: nil)
        
        // notification related to the ContactManagerService
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
        
        // notifications related to unread conversation count
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidEndLoadingConversations), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidUpdateMessagesUnreadCount), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsButton.isEnabled = contactsLoaded
        conversationsButton.isEnabled = conversationsLoaded
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unreadMessagesCountLabel.text = "\(totalNbOfUnreadMessagesInAllConversations)"
    }
    
    // MARK: - LoginManager notifications
    
    @objc func didLogin(notification : NSNotification) {
        NSLog("Did login")
        self.reconnecting = false
    }
    
    @objc func didReconnect(notification : NSNotification) {
        NSLog("Did reconnect")
        self.reconnecting = true
        ServicesManager.sharedInstance().loginManager.disconnect()
        ServicesManager.sharedInstance().loginManager.connect()
    }
    
    @objc func didLogout(notification : NSNotification) {
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                self.didLogout(notification: notification)
            }
            return
        }
        NSLog("Did logout")
        if !self.reconnecting {
            self.performSegue(withIdentifier: "BackToLoginSegue", sender:self)
        }
    }
    
    @objc func failedToAuthenticate(notification : NSNotification) {
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                self.failedToAuthenticate(notification: notification)
            }
        }
        NSLog("Failed to login")
        self.performSegue(withIdentifier: "BackToLoginSegue", sender: self)
    }
    
    // MARK: - ContactManagerService notifications
    
    @objc func didEndPopulatingMyNetwork(notification : Notification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didEndPopulatingMyNetwork(notification: notification)
            }
            return
        }
        NSLog("Did end populating my network");
        contactsLoaded = true
        if isViewLoaded {
            contactsButton.isEnabled = true
        }
    }
    
    // MARK: - Notifications related to unread conversation count
    
    @objc func didEndLoadingConversations(notification : Notification) {
        conversationsLoaded = true
        // Read the unread message count in a asynchronous block as it is a synchronous method protected by a lock
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.conversationsButton.isEnabled = true
                }
            }
            self.totalNbOfUnreadMessagesInAllConversations = ServicesManager.sharedInstance().conversationsManagerService.totalNbOfUnreadMessagesInAllConversations
            NSLog("totalNbOfUnreadMessagesInAllConversations=%ld", self.totalNbOfUnreadMessagesInAllConversations)
        }
    }
    
    @objc func didUpdateMessagesUnreadCount(notification : Notification) {
        // Read the unread message count in a asynchronous block as it is a synchronous method protected by a lock
        DispatchQueue.global().async {
            self.totalNbOfUnreadMessagesInAllConversations = ServicesManager.sharedInstance().conversationsManagerService.totalNbOfUnreadMessagesInAllConversations
            NSLog("totalNbOfUnreadMessagesInAllConversations=%ld", self.totalNbOfUnreadMessagesInAllConversations)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func logoutAction(_ sender: Any) {
        ServicesManager.sharedInstance().loginManager.disconnect()
        ServicesManager.sharedInstance().loginManager.resetAllCredentials()
    }
    

}