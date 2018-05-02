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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin(notification:)), name: NSNotification.Name(kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout(notification:)), name: NSNotification.Name(kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToAuthenticate(notification:)), name: NSNotification.Name(kLoginManagerDidFailedToAuthenticate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndPopulatingMyNetwork(notification:)), name: NSNotification.Name(kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidFailedToAuthenticate), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsButton.isEnabled = false
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
