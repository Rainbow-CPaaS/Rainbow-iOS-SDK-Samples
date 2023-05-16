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

class EditRoomViewController: UIViewController {
    let serviceManager : ServicesManager
    let roomsManager : RoomsService
    var room : Room? = nil
    var roomImage : UIImage = UIImage.init(named: "Default_Room_Avatar")!
    var roomImageTint = UIColor.clear
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var topicTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        serviceManager = ServicesManager.sharedInstance()
        roomsManager = serviceManager.roomsService
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit room informations"
        self.avatar.image = self.roomImage;
        self.avatar.tintColor = self.roomImageTint;
        if let room = room {
            nameTextField.text = room.displayName
            topicTextField.text = room.topic
            ownerNameLabel.text = room.isMyRoom ? "Me" : room.creator.displayName
            nameTextField.isEnabled = room.isMyRoom
            topicTextField.isEnabled = room.isMyRoom
            updateButton.isEnabled = room.isMyRoom
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateRoom(notification:)), name: NSNotification.Name(kRoomsServiceDidUpdateRoom), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func updateAction(_ sender: Any) {
        if let name = nameTextField.text, let topic = topicTextField.text, let room = room {
            roomsManager.updateRoom(room, name: name, topic: topic)
        }
        nameTextField.resignFirstResponder()
        topicTextField.resignFirstResponder()
    }
    
    @objc func didUpdateRoom(notification : NSNotification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didUpdateRoom(notification: notification)
            }
            return
        }
        
        if let roomInfo = notification.object as? Dictionary<String, AnyObject> {
            let room = roomInfo[kRoomKey]! as! Room
            NSLog("didUpdate room with name=%@", room.displayName)
        } else {
            NSLog("didUpdate room without roomInfo !")
        }
    }
}
