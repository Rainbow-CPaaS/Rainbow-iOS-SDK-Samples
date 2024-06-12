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
    private var videoCall = false
    
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
            ownerNameLabel.text = room.isMyRoom ? "Me" : room.creator?.displayName
            nameTextField.isEnabled = room.isMyRoom
            topicTextField.isEnabled = room.isMyRoom
            updateButton.isEnabled = room.isMyRoom
        }
    }
    
    func configureRightButton(room : Room) {
        var actions : [UIAction] = []
        
        let openConversation = UIAction(title: "Open conversation", image: UIImage(systemName: "person.2.fill")) { _ in
            self.openConversation(self)
        }
        actions.append(openConversation)
        
        if room.isAbleToJoinConference() {
            let joinConference = UIAction(title: "Join conference", image: UIImage(systemName: "phone.badge.waveform.fill")) { _ in
                if let roomId = room.rainbowID {
                    ServicesManager.sharedInstance().conferencesManagerService.join(roomId) { error in
                        if let error = error as? NSError {
                            NSLog("Join conference error: \(error.localizedDescription)")
                        } else {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "ConferenceSegue", sender:self)
                            }
                        }
                        
                    }
                }
            }
            actions.append(joinConference)
            
        } else if room.isAbleToStartConference() {
            let startConference = UIAction(title: "Start audio conference", image: UIImage(systemName: "phone.connection.fill")) { _ in
                self.videoCall = false
                self.performSegue(withIdentifier: "ConferenceSegue", sender:self)
                ServicesManager.sharedInstance().conferencesManagerService.startOrJoin(room, forceLocalVideo: false)
            }
            actions.append(startConference)

            let startVideoConference = UIAction(title: "Start video conference", image: UIImage(systemName: "person.crop.square.badge.video")) { _ in
                self.videoCall = true
                self.performSegue(withIdentifier: "ConferenceSegue", sender:self)
                ServicesManager.sharedInstance().conferencesManagerService.startOrJoin(room, forceLocalVideo: true)
            }
            actions.append(startVideoConference)

        }
        
        let menu = UIMenu(title: "", children: actions)
        let barButton = UIBarButtonItem(title: "", image: UIImage(systemName: "ellipsis"), menu: menu)
        navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let room = room {
            configureRightButton(room: room)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateRoom(notification:)), name: NSNotification.Name(kRoomsServiceDidUpdateRoom), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConferenceSegue",
            let conferenceVC = segue.destination as? ConferenceViewController {
            conferenceVC.room = room
            conferenceVC.videoCall = self.videoCall
        }
    }

    @IBAction func updateAction(_ sender: Any) {
        if let name = nameTextField.text, let topic = topicTextField.text, let room = room {
            roomsManager.updateRoom(room, name: name, topic: topic)
        }
        nameTextField.resignFirstResponder()
        topicTextField.resignFirstResponder()
    }
    
    @objc func openConversation(_ sender: Any) {
        if let peer = self.room {
            self.serviceManager.conversationsManagerService.startConversation(withPeer: peer) {(conversation : Optional<Conversation>, error : Optional<Error>)  in
                if let error = error as? NSError {
                    NSLog("[EditRoomViewController] Can't start the conversation, error: \(error.debugDescription)")
                }
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func didUpdateRoom(notification : NSNotification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didUpdateRoom(notification: notification)
            }
            return
        }
        
        if let roomInfo = notification.object as? Dictionary<String, AnyObject>, let room = roomInfo[kRoomKey] as? Room {
            NSLog("[EditRoomViewController] didUpdateRoom '\(room.displayName ?? "")' with roomInfo=\(roomInfo)")
            // Update the right button menu as the state of the conference may have changed
            configureRightButton(room: room)
            
        } else {
            NSLog("[EditRoomViewController] didUpdateRoom without roomInfo !")
        }
    }
}
