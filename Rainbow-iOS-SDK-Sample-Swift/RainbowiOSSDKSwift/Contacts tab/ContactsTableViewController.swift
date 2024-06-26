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

class ContactsTableViewController: UITableViewController {
    let serviceManager : ServicesManager
    let contactsManager : ContactsManagerService
    var populated = false
    var selectedIndex : IndexPath? = nil
    var allObjects : [Contact] = []
    
    private var contactCellIdentifier = "ContactTableViewCell"
    
    required init?(coder aDecoder: NSCoder) {
        serviceManager = ServicesManager.sharedInstance()
        contactsManager = serviceManager.contactsManagerService
        super.init(coder: aDecoder)
    }
    
    deinit {
        selectedIndex = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        allObjects = []
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didAddContact(notification:)), name: NSNotification.Name(kContactsManagerServiceDidAddContact), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateContact(notification:)), name: NSNotification.Name(kContactsManagerServiceDidUpdateContact), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveContact(notification:)), name: NSNotification.Name(kContactsManagerServiceDidRemoveContact), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndPopulatingMyNetwork), name: NSNotification.Name(kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
        if (!populated) {
            self.didEndPopulatingMyNetwork()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kContactsManagerServiceDidAddContact), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kContactsManagerServiceDidUpdateContact), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kContactsManagerServiceDidRemoveContact), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)

    }
    
    func insert(_ contact : Contact) {
        // Ignore myself
        if contact == serviceManager.myUser.contact {
            return
        }
        
        // Only handle RainbowContact (no external contact)
        if let rainbowContact = contact as? RainbowContact {
            // Ignore contact not in roster
            if !rainbowContact.isInRoster {
                return
            }
            // Ignore bots
            if rainbowContact.isBot {
                return
            }
            
            if let index = allObjects.firstIndex(of: contact) {
                allObjects[index] = contact
            } else {
                allObjects.append(contact)
            }
        }
    }
    
    @objc func didAddContact(notification : Notification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didAddContact(notification: notification)
            }
            return
        }
        
        if let contact = notification.object as? Contact {
            self.insert(contact)
            if self.isViewLoaded && populated {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func didUpdateContact(notification : NSNotification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didUpdateContact(notification: notification)
            }
            return
        }
        
        if let userInfo = notification.object as? Dictionary<String, AnyObject> {
            if let contact = userInfo[kContactKey]! as? RainbowContact {
                if contact.isInRoster {
                    self.insert(contact)
                }
                else {
                    if let index = allObjects.firstIndex(of: contact) {
                        if (index != NSNotFound) {
                            self.allObjects.remove(at: index)
                        }
                    }
                }
                if self.isViewLoaded && populated {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func didRemoveContact(notification : NSNotification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didRemoveContact(notification: notification)
            }
            return
        }
        if let contact = notification.object as? Contact {
            if let index = allObjects.firstIndex(of: contact) {
                self.allObjects.remove(at: index)
            }
            if self.isViewLoaded && populated {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func didEndPopulatingMyNetwork() {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didEndPopulatingMyNetwork()
            }
            return
        }
        for contact in contactsManager.myNetworkContacts {
            self.insert(contact)
        }
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
        populated = true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allObjects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactCellIdentifier, for: indexPath)
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let contactCell = cell as? ContactTableViewCell {
            let contact = allObjects[indexPath.row]
            contactCell.name.text = contact.fullName
            if let photoData = contact.photoData {
                contactCell.avatar.image = UIImage.init(data: photoData)
                contactCell.avatar.tintColor = UIColor.clear
            } else {
                contactCell.avatar.image = UIImage.init(named: "Default_Avatar")
                contactCell.avatar.tintColor = UIColor.init(hue: CGFloat(indexPath.row*36%100)/100.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowContactDetailSegue", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "ShowContactDetailSegue" {
            if let selectedIndex = self.selectedIndex {
                if let vc = segue.destination as? DetailViewController, let contact =  allObjects[selectedIndex.row] as? RainbowContact {
                    vc.contact = contact
                    if let cell = self.tableView.cellForRow(at: selectedIndex) as? ContactTableViewCell {
                        vc.contactImage = cell.avatar.image!
                        vc.contactImageTint = cell.avatar.tintColor
                    }
                }
            }
        }
    }
    
}
