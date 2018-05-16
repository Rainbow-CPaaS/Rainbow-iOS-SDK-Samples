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
    let rainbowServer = "openrainbow.com"
    var server : String?
    
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let login = self.loginTextField.text {
            if let passwd = self.passwordTextField.text {
                if login.count > 0 && passwd.count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "LoginSegue" {
            ServicesManager.sharedInstance().loginManager.setUsername(self.loginTextField.text, andPassword: self.passwordTextField.text)
            ServicesManager.sharedInstance().loginManager.connect()
        }
    }
    
    @objc func didChangeServer(notification: NSNotification) {
        if let server = notification.object as? Server {
            NSLog("Did changed server to : %@", server.serverDisplayedName)
        }
    }
}

