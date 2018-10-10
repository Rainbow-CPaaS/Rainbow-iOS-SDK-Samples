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

class LoginViewController: UIViewController {
    let rainbowServer = "sandbox.openrainbow.com"
    var server : String?
    var doLogout = false
    
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.server = rainbowServer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.serverLabel.text = self.server
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeServer(notification:)), name: NSNotification.Name(kLoginManagerDidChangeServer), object: nil)

        if let server = self.server {
            NotificationCenter.default.post(name: NSNotification.Name(kChangeServerURLNotification), object: ["serverURL" : server])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if let username = ServicesManager.sharedInstance().myUser.username {
            loginTextField.text = username
        }
        if let passwd = ServicesManager.sharedInstance().myUser.password {
            passwordTextField.text = passwd
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didLogin(notification:)), name: NSNotification.Name(kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReconnect(notification:)), name: NSNotification.Name(kLoginManagerDidReconnect), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout(notification:)), name: NSNotification.Name(kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToAuthenticate(notification:)), name: NSNotification.Name(kLoginManagerDidFailedToAuthenticate), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidReconnect), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidFailedToAuthenticate), object: nil)
    }
    
    // MARK: - LoginManager notifications
    
    @objc func didLogin(notification : NSNotification) {
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                self.didLogin(notification: notification)
            }
            return
        }
        NSLog("[LoginViewController] Did login")
        loginButton.isEnabled = true
        performSegue(withIdentifier: "DidLoginSegue", sender: self)
    }
    
    @objc func didReconnect(notification : NSNotification) {
        NSLog("[LoginViewController] Did reconnect")
        ServicesManager.sharedInstance().loginManager.disconnect()
        ServicesManager.sharedInstance().loginManager.connect()
    }
    
    @objc func failedToAuthenticate(notification : NSNotification) {
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                self.failedToAuthenticate(notification: notification)
            }
            return
        }
        NSLog("[LoginViewController] Failed to login")
        self.loginButton.isEnabled = true
        self.passwordTextField.text = ""
    }
    
    @objc func didLogout(notification : NSNotification) {
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                self.didLogout(notification: notification)
            }
            return
        }
        NSLog("[LoginViewController] Did logout")
    }
    
    @objc func didChangeServer(notification: NSNotification) {
        if let server = notification.object as? Server {
            NSLog("[LoginViewController] Did changed server to : %@", server.serverDisplayedName)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        DispatchQueue.global().async {
            ServicesManager.sharedInstance().loginManager.disconnect()
            ServicesManager.sharedInstance().loginManager.resetAllCredentials()
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if let login = self.loginTextField.text, let passwd = self.passwordTextField.text {
            if login.count > 0 && passwd.count > 0 {
                self.loginButton.isEnabled = false
                ServicesManager.sharedInstance().loginManager.setUsername(login, andPassword:passwd)
                ServicesManager.sharedInstance().loginManager.connect()
            }
        }
    }
    
}

