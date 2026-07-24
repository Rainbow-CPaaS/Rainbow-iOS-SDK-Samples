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
    
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton : UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.serverLabel.text = rainbowServer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if (ServicesManager.sharedInstance().myUser.username != nil) && (ServicesManager.sharedInstance().myUser.password != nil) {
            self.loginTextField.text = ServicesManager.sharedInstance().myUser.username
            self.passwordTextField.text = ServicesManager.sharedInstance().myUser.password
            ServicesManager.sharedInstance().loginManager.connectToServer()
            activityIndicatorView.startAnimating()
            self.loginButton.isEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin(notification:)), name: LoginManager.Notifications.didLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReconnect(notification:)), name: LoginManager.Notifications.didReconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLogout(notification:)), name: LoginManager.Notifications.didLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToAuthenticate(notification:)), name: LoginManager.Notifications.didFailedToAuthenticate, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        activityIndicatorView.stopAnimating()
        performSegue(withIdentifier: "DidLoginSegue", sender: self)
    }
    
    @objc func didReconnect(notification : NSNotification) {
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                self.didReconnect(notification: notification)
            }
            return
        }
        NSLog("[LoginViewController] Did reconnect")
        loginButton.isEnabled = true
        activityIndicatorView.stopAnimating()
        performSegue(withIdentifier: "DidLoginSegue", sender: self)
    }
    
    @objc func failedToAuthenticate(notification : NSNotification) {
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                self.failedToAuthenticate(notification: notification)
            }
            return
        }
        NSLog("[LoginViewController] Failed to login")
        activityIndicatorView.stopAnimating()
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
        self.loginButton.isEnabled = true
        self.passwordTextField.text = ""
        activityIndicatorView.stopAnimating()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        Task { @MainActor in
            try? await ServicesManager.sharedInstance().loginManager.logout()
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if let login = self.loginTextField.text, let passwd = self.passwordTextField.text {
            if login.count > 0 && passwd.count > 0 {
                self.signin(loginEmail: login, password: passwd, server: rainbowServer)
                activityIndicatorView.startAnimating()
                self.loginButton.isEnabled = false
            }
        }
    }
    
    func signin(loginEmail: String, password: String, server: String? = nil) {
        Task {
            if let server {
                NSLog("Switch server then, sign in with loginEmail and password")
                try? await ServicesManager.sharedInstance().loginManager.switchToServer(server, withLogin: loginEmail, andPassword: password)
            } else {
                NSLog("Will sign in with loginEmail and password")
                try? await ServicesManager.sharedInstance().loginManager.login(withUsername: loginEmail, andPassword: password)
            }
        }
    }
    
}

