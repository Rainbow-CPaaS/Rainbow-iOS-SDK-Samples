//
//  ViewController.swift
//  Hello World
//
//  Created by Vladimir Vyskocil on 10/10/2023.
//

import UIKit
import Rainbow

class ViewController: UIViewController {
    
    @IBOutlet weak var userFullname: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userPresence: UILabel!
    
    func signin(loginEmail: String, password: String, server: String? = nil) {
        if let server {
            NSLog("Switch server then, sign in with loginEmail and password")
            ServicesManager.sharedInstance().loginManager.switchServer(server, login:loginEmail, password: password)
        } else {
            NSLog("Will sign in with loginEmail and password")
            ServicesManager.sharedInstance().loginManager.setUsername(loginEmail, andPassword: password)
            ServicesManager.sharedInstance().loginManager.connect()
        }
    }
    
    func signout() {
        ServicesManager.sharedInstance()?.loginManager.disconnect()
        // Optional - Completely clean the device
        ServicesManager.sharedInstance().loginManager.resetAllCredentials()
    }
    
    func updateUserPassword(current: String, newPassword: String ) {
        if (ServicesManager.sharedInstance().loginManager.isConnected) {

            ServicesManager.sharedInstance().loginManager.sendChangePassword(current, newPassword: newPassword, completionHandler: { (dictionary: Optional<Dictionary<AnyHashable, Any>>, error:Optional<Error>) in
                if (error != nil) {
                    print(error.debugDescription)
                } else {
                    //Do something when password has been changed
                }
            })

        }
    }
    
    func updateConnectedUser() {
        // Try to access the user information
        guard let userContact = ServicesManager.sharedInstance()?.myUser.contact,
              let name = userContact.fullName,
              let companyName = userContact.companyName,
              let presence = Presence.string(forContactPresence: userContact.presence)
        else {
            resetUserInformation()
            return
        }

        let avatar = userContact.photoData ?? Data()

        updateUserInformation(name: name, nameOfCompany: companyName, avatar: avatar, presence: presence)
    }

    func updateUserInformation(name: String = "", nameOfCompany: String = "", avatar: Data = Data(), presence: String = "") {
        // Uddate some labels
        userFullname.text = name
        companyName.text = nameOfCompany
        userPresence.text = presence
        // Update an ImageView containing the user avatar
        userPhoto.image = UIImage(data: avatar)
    }

    func resetUserInformation() {
        // Display empty fields when no user
        updateUserInformation()
    }

    // MARK: - Rainbow event handlers
    
    @objc func didLogin(notification: NSNotification) {
        // Do something when logged
        NSLog("didLogin")
        DispatchQueue.main.async {
            self.updateConnectedUser()
        }
    }

    @objc func failedToLogin(notification: NSNotification) {
        // Do something in case of failure during the authentication step
        NSLog("failedToLogin")
    }
    
    @objc func didLogout(notification: NSNotification) {
        // Do something once the user has been logged-out from Rainbow
        NSLog("didLogout")
    }

    @objc func didReconnect(notification: NSNotification) {
        // Do something once reconnected from a previous session
        NSLog("didReconnect")
        DispatchQueue.main.async {
            self.updateConnectedUser()
        }
    }

    @objc func didTryToReconnect(notification: NSNotification) {
        // Do something during the reconnection
        NSLog("didTryToReconnect")
    }
    
    @objc func didLostConnection(notification: NSNotification) {
        // Do something once disconnected from Rainbow
        NSLog("didLostConnection")
    }

    @objc func didUpdateConnectedUserInformation(notification: NSNotification) {

        DispatchQueue.main.async {
            self.updateConnectedUser()
        }
    }

    // MARK: - View related notifications
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("viewDidLoad")
        
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin(notification:)), name: NSNotification.Name(kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToLogin(notification:)), name: NSNotification.Name(kLoginManagerDidFailedToAuthenticate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout(notification:)), name: NSNotification.Name(kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReconnect(notification:)), name: NSNotification.Name(kLoginManagerDidReconnect), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTryToReconnect(notification:)), name: NSNotification.Name(kLoginManagerTryToReconnect), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLostConnection(notification:)), name: NSNotification.Name(kLoginManagerDidLostConnection), object: nil)
        
        // Add the following listener to receive change on the connected user profile information
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateConnectedUserInformation(notification:)), name: NSNotification.Name(kContactsManagerServiceDidUpdateMyContact), object: nil)


        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            signin(loginEmail:appDelegate.loginEmail, password: appDelegate.password, server: appDelegate.rainbowServer)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func doLogout(_ sender: Any) {
        signout()
        resetUserInformation()
    }
    

}

