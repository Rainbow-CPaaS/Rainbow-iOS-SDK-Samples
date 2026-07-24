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
    let roomsManager : RoomService
    var room : Room? = nil
    var roomImage : UIImage = UIImage.init(named: "Default_Room_Avatar")!
    var roomImageTint = UIColor.clear
    private var videoCall = false
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var conferenceLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var topicTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        serviceManager = ServicesManager.sharedInstance()
        roomsManager = serviceManager.roomService
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateRoom(notification:)), name: RoomService.Notifications.didUpdateRoom, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didAddCall(notification:)), name:NSNotification.Name(kTelephonyServiceDidAddCall), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRemoveCall(notification:)), name:NSNotification.Name(kTelephonyServiceDidRemoveCall), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit room informations"
        
        self.avatar.image = self.roomImage;
        self.avatar.tintColor = self.roomImageTint;
        if let room = room {
            let isMyRoom = {
                guard let myContact = ServicesManager.sharedInstance().myUser.contact else { return false }
                return room.isOwner(contact: myContact)
            }()
            
            nameTextField.text = room.displayName()
            topicTextField.text = room.topic
            ownerNameLabel.text = isMyRoom ? "Me" : room.creator?.displayName
            nameTextField.isEnabled = isMyRoom
            topicTextField.isEnabled = isMyRoom
            updateButton.isEnabled = isMyRoom
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let room = room {
            configureRightButton(room: room)
            updateConferenceState()
        }
    }
    
    // MARK: - Segue navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConferenceSegue",
            let conferenceVC = segue.destination as? ConferenceViewController {
            conferenceVC.room = room
            conferenceVC.videoCall = self.videoCall
            let backItem = UIBarButtonItem()
            backItem.title = "Hangup"
            navigationItem.backBarButtonItem = backItem
        }
    }

    // MARK: - IBActions
    
    @IBAction func updateAction(_ sender: Any) {
        if let name = nameTextField.text, let topic = topicTextField.text, let room = room {
            Task {
                try? await roomsManager.update(room, withName: name, topic: topic)
            }
        }
        nameTextField.resignFirstResponder()
        topicTextField.resignFirstResponder()
    }
    
    // MARK: - Room service notifications
    
    @objc func didUpdateRoom(notification : NSNotification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didUpdateRoom(notification: notification)
            }
            return
        }
        
        if let roomInfo = notification.object as? Dictionary<String, AnyObject>, let room = roomInfo[RoomService.Constants.kRoomKey] as? Room {
            NSLog("[EditRoomViewController] didUpdateRoom '\(String(describing: room.displayName()))' with roomInfo=\(roomInfo)")
            // Update the right button menu as the state of the conference may have changed
            configureRightButton(room: room)
            updateConferenceState()
            
        } else {
            NSLog("[EditRoomViewController] didUpdateRoom without roomInfo !")
        }
    }
    
    // MARK: - Telephony service notifications
    
    @objc func didRemoveCall(notification : NSNotification) {
        NSLog("[EditRoomViewController] didRemoveCall")
        
        if let room {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.configureRightButton(room: room)
                self.updateConferenceState()
            }
        }
    }
    
    @objc func didAddCall(notification : NSNotification) {
        NSLog("[EditRoomViewController] didAddCall")
        
        if let room {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.configureRightButton(room: room)
                self.updateConferenceState()
            }
        }
    }
    
    // MARK: - utility methods
    
    func updateConferenceState() {
        if let conference = room?.conference {
            conferenceLabel.text = "started"
        } else {
            conferenceLabel.text = "not started"
        }
    }
    
    func openConversation() {
        guard let peer = room else {
            return
        }
        
        Task { @MainActor in
            do {
                let _ = try await serviceManager.conversationsManagerService.startConversation(with: peer)
                self.navigationController?.popViewController(animated: true)
            } catch {
                NSLog("[EditRoomViewController] Can't start the conversation, error: \(error)")
            }
        }
    }
    
    func configureRightButton(room : Room) {
        var actions : [UIAction] = []
        
        let openConversation = UIAction(title: "Open conversation", image: UIImage(systemName: "person.2.fill")) { _ in
            self.openConversation()
        }
        actions.append(openConversation)
        
        if roomsManager.canIJoinConference(in: room) {
            let joinConference = UIAction(title: "Join conference", image: UIImage(systemName: "phone.badge.waveform.fill")) { _ in
                self.videoCall = false
                Task { @MainActor in
                    do {
                        try await ServicesManager.sharedInstance().conferenceService.joinTheConference(in: room)
                        self.performSegue(withIdentifier: "ConferenceSegue", sender:self)
                    } catch {
                        NSLog("Join conference error: \(error)")
                    }
                }
            }
            actions.append(joinConference)
            
            if ServicesManager.sharedInstance().myUser.isAllowedToUseWebRTCMobileVideo {
                let joinConferenceWithVideo = UIAction(title: "Join conference with video", image: UIImage(systemName: "video.badge.waveform.fill")) { _ in
                    self.videoCall = true
                    Task { @MainActor in
                        do {
                            try await ServicesManager.sharedInstance().conferenceService.joinTheConference(in: room, activateMyVideo: true)
                            self.performSegue(withIdentifier: "ConferenceSegue", sender:self)
                        } catch {
                            NSLog("Join conference error: \(error)")
                        }
                    }
                }
                actions.append(joinConferenceWithVideo)
            }
            
        } else if roomsManager.canIStartConference(in: room) {
            let startConference = UIAction(title: "Start audio conference", image: UIImage(systemName: "phone.connection.fill")) { _ in
                self.videoCall = false
                Task { @MainActor in
                    do {
                        try await ServicesManager.sharedInstance().conferenceService.startTheConference(in: room)
                        self.performSegue(withIdentifier: "ConferenceSegue", sender:self)
                    } catch {
                        NSLog("Start conference error: \(error)")
                    }
                }
            }
            actions.append(startConference)

            if ServicesManager.sharedInstance().myUser.isAllowedToUseWebRTCMobileVideo {
                let startVideoConference = UIAction(title: "Start video conference", image: UIImage(systemName: "person.crop.square.badge.video")) { _ in
                    self.videoCall = true
                    Task { @MainActor in
                        do {
                            try await ServicesManager.sharedInstance().conferenceService.startTheConference(in: room, activateMyVideo: true)
                            self.performSegue(withIdentifier: "ConferenceSegue", sender:self)
                        } catch {
                            NSLog("Start conference error: \(error)")
                        }
                    }
                }
                actions.append(startVideoConference)
            }

        }
        
        let menu = UIMenu(title: "", children: actions)
        let barButton = UIBarButtonItem(title: "", image: UIImage(systemName: "ellipsis"), menu: menu)
        navigationItem.rightBarButtonItem = barButton
    }
    
}
