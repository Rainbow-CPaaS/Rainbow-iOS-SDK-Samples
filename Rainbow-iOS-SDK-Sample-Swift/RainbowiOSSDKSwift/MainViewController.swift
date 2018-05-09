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
    @IBOutlet weak var unreadMessagesCountLabel: UILabel!
    
    var totalNbOfUnreadMessagesInAllConversations = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // notifications related to the authentification on the server
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin(notification:)), name: NSNotification.Name(kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout(notification:)), name: NSNotification.Name(kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToAuthenticate(notification:)), name: NSNotification.Name(kLoginManagerDidFailedToAuthenticate), object: nil)
        // notification related to contact loading
        NotificationCenter.default.addObserver(self, selector: #selector(didEndPopulatingMyNetwork(notification:)), name: NSNotification.Name(kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
        // notifications related to unread conversation count
        NotificationCenter.default.addObserver(self, selector: #selector(didEndLoadingConversations(notification:)), name:NSNotification.Name(kConversationsManagerDidEndLoadingConversations), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateMessagesUnreadCount(notification:)), name:NSNotification.Name(kConversationsManagerDidUpdateMessagesUnreadCount), object: nil)
    }
    
    deinit {
        // notifications related to the authentification on the server
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidFailedToAuthenticate), object: nil)
        // notification related to contact loading
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
        // notifications related to unread conversation count
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidEndLoadingConversations), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidUpdateMessagesUnreadCount), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsButton.isEnabled = false
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unreadMessagesCountLabel.text = "\(totalNbOfUnreadMessagesInAllConversations)"
    }
    
    @objc func didEndPopulatingMyNetwork(notification : Notification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didEndPopulatingMyNetwork(notification: notification)
            }
            return
        }
        NSLog("Did end populating my network");
        contactsButton.isEnabled = true
    }
    
    @objc func didEndLoadingConversations(notification : Notification) {
        // Read the unread message count in a asynchronous block as it is a synchronous method protected by a lock
        DispatchQueue.main.async {
            self.totalNbOfUnreadMessagesInAllConversations = ServicesManager.sharedInstance().conversationsManagerService.totalNbOfUnreadMessagesInAllConversations
            NSLog("totalNbOfUnreadMessagesInAllConversations=%ld", self.totalNbOfUnreadMessagesInAllConversations)
        }
    }
    
    @objc func didUpdateMessagesUnreadCount(notification : Notification) {
        // Read the unread message count in a asynchronous block as it is a synchronous method protected by a lock
        DispatchQueue.main.async {
            self.totalNbOfUnreadMessagesInAllConversations = ServicesManager.sharedInstance().conversationsManagerService.totalNbOfUnreadMessagesInAllConversations
            NSLog("totalNbOfUnreadMessagesInAllConversations=%ld", self.totalNbOfUnreadMessagesInAllConversations)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        ServicesManager.sharedInstance().loginManager.disconnect()
        ServicesManager.sharedInstance().loginManager.resetAllCredentials()
    }
    
    @objc func didLogin(notification : NSNotification) {
        NSLog("Did login")
    }
    
    @objc func didLogout(notification : NSNotification) {
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                self.didLogout(notification: notification)
            }
            return
        }
        NSLog("Did logout")
        self.performSegue(withIdentifier: "BackToLoginSegue", sender:self)
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
}
