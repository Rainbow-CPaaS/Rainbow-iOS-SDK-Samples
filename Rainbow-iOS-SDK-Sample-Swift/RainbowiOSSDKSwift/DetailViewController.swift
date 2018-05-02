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

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var contact : Contact? = nil
    var contactImage : UIImage = UIImage.init(named: "Default_Avatar")!
    var contactImageTint = UIColor.clear
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var infoList: UITableView!
    
    var sectionHeaders : [String] = []
    
    let phoneNumbersStr = "Phone numbers"
    let eMailsStr = "eMails"
    
    func updateUI(_ contact : Contact) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.updateUI(contact)
            }
            return
        }
        
        self.nameLabel.text = contact.fullName;
        self.companyLabel.text = contact.companyName;
        self.avatar.image = self.contactImage;
        self.avatar.tintColor = self.contactImageTint;
        
        self.sectionHeaders = []
        if (contact.phoneNumbers != nil) && contact.phoneNumbers.count>0 {
            self.sectionHeaders.append(phoneNumbersStr)
        }
        if (contact.emailAddresses != nil) && contact.emailAddresses.count>0 {
            self.sectionHeaders.append(eMailsStr)
        }
        
        self.infoList.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let contact = self.contact {
            // Update the UI with already fetched informations
            self.updateUI(contact)
            
            // Fetch potentially missing informations about the contact
            NotificationCenter.default.addObserver(self, selector: #selector(didGetInfo(notification:)), name: NSNotification.Name(kContactsManagerServiceDidUpdateContact), object: nil)
            ServicesManager.sharedInstance().contactsManagerService.fetchRemoteContactDetail(contact)
        }
    }

    // MARK: - get contact info notification
    
    @objc func didGetInfo(notification : Notification) {
        if let contact = notification.object as? Contact {
            self.updateUI(contact)
        }
    }

    // MARK: - table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let contact = self.contact {
            if self.sectionHeaders[section] == phoneNumbersStr {
                return contact.phoneNumbers.count
            } else if self.sectionHeaders[section] == eMailsStr {
                return contact.emailAddresses.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section : Int) -> String? {
        return self.sectionHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath)
        return cell
    }
    
    // MARK: - table view delegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let contact = self.contact {
            if self.sectionHeaders[indexPath.section] == phoneNumbersStr {
                cell.textLabel?.text = contact.phoneNumbers[indexPath.row].label
                cell.detailTextLabel?.text = contact.phoneNumbers[indexPath.row].number
            } else if self.sectionHeaders[indexPath.section] == eMailsStr {
                cell.textLabel?.text = contact.emailAddresses[indexPath.row].label
                cell.detailTextLabel?.text = contact.emailAddresses[indexPath.row].address
            }
        }
    }
}
