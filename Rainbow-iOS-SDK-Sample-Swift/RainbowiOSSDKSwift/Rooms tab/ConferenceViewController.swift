/*
 * Rainbow SDK sample
 *
 * Copyright (c) 2024, ALE International
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
import WebRTC

class ConferenceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // The room where the conference is running
    var room : Room?
    // true if we start the conference with local video on
    var videoCall = false
    
    @IBOutlet weak var conferenceStatus: UILabel!
    @IBOutlet weak var participantTableView: UITableView!
    
    private var localVideoView : RTCMTLVideoView?
    private var remoteVideoViews: [String:RTCMTLVideoView] = [:]
    private let participantCellIdentifier = "ConferenceParticipantCell"
    private var participants : [ConferenceParticipant] = []
    
    private var cameraCaptureSession : AVCaptureSession?
    private var localVideoTrack : RTCVideoTrack?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        participantTableView.register(UINib(nibName: "ConferenceTableViewCell", bundle: nil), forCellReuseIdentifier: participantCellIdentifier)
        participantTableView.delegate = self
        participantTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen to 'kConferencesManagerDidUpdateConference' ConferencesManagerService events
        NotificationCenter.default.addObserver(self, selector:#selector(didUpdateConference(notification:)), name:NSNotification.Name(kConferencesManagerDidUpdateConference), object:nil)
        
        // WebRTC audio call handling
        NotificationCenter.default.addObserver(self, selector:#selector(didAddCall(notification:)), name:NSNotification.Name(kTelephonyServiceDidAddCall), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didUpdateCall(notification:)), name:NSNotification.Name(kTelephonyServiceDidUpdateCall), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRemoveCall(notification:)), name:NSNotification.Name(kTelephonyServiceDidRemoveCall), object: nil)
        
        // Local video notifications
        NotificationCenter.default.addObserver(self, selector:#selector(didAddCaptureSession(notification:)), name:NSNotification.Name(kRTCServiceDidAddCaptureSession), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didAddLocalVideoTrack(notification:)), name:NSNotification.Name(kRTCServiceDidAddLocalVideoTrack), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRemoveLocalVideoTrack(notification:)), name:NSNotification.Name(kRTCServiceDidRemoveLocalVideoTrack), object: nil)
        
        // Remote video notifications
        NotificationCenter.default.addObserver(self, selector: #selector(didAddRemoteVideoTrack(notification:)), name: NSNotification.Name(kRTCServiceDidAddRemoteVideoTrack), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveRemoteVideoTrack(notification:)), name: NSNotification.Name(kRTCServiceDidRemoveRemoteVideoTrack), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didAddPublisher(notification:)), name: NSNotification.Name(kConferencesManagerDidAddPublisher), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemovePublisher(notification:)), name: NSNotification.Name(kConferencesManagerDidRemovePublisher), object: nil)
        
        // Microphone notifications
        NotificationCenter.default.addObserver(self, selector:#selector(didAllowMicrophone(notification:)), name:NSNotification.Name(kRTCServiceDidAllowMicrophone), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRefuseMicrophone(notification:)), name:NSNotification.Name(kRTCServiceDidRefuseMicrophone), object: nil)
        
        // Mute/unmute notifications
        NotificationCenter.default.addObserver(self, selector:#selector(didReceiveUnmuteRequest(notification:)), name:NSNotification.Name(kConferencesManagerDidReceiveUnmuteRequest), object: nil)
    }
    
    // MARK: - Segue navigation
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil, let room = room {
            NSLog("Back pressed")
            
            // Allow some time after back is pressed before doing the hangup
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Terminate the conference when the back button is pressed
                ServicesManager.sharedInstance().conferencesManagerService.hangup(room) {
                    error in
                    if let error = error as? NSError {
                        NSLog("Error: ", error.localizedDescription)
                    }
                    NotificationCenter.default.removeObserver(self)
                }
            }
        }
    }
    
    // MARK: - Notification handlers
    
    @objc func didUpdateConference(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didUpdateConference(notification: notification)
            }
            return
        }
        
        if let notificationDict = notification.object as? Dictionary<String, Any>,
           let theRoom = notificationDict[kRoomKey] as? Room,
           let changedAttributes = notificationDict[kConferenceChangedAttributesKey] as? Array<String> {
            NSLog("[ConferenceViewController] didUpdateConference: room: '\(theRoom.displayName ?? "")' changed attributes: \(changedAttributes)")
            
            // Check if a conference was started or terminated in the room
            if changedAttributes.contains("conference"){
                if room?.conference != nil {
                    conferenceStatus.text = "Connected"
                    NSLog("[ConferenceViewController] didUpdateConference: conference is connected")
                } else {
                    conferenceStatus.text = "Disconnected"
                    NSLog("[ConferenceViewController] didUpdateConference: conference is disconnected")
                }
            }
            
            // Handle conference participant being added or removed
            if changedAttributes.contains("participants") {
                NSLog("[ConferenceViewController] didUpdateConference: participants: \(theRoom.conference?.participants ?? [])")
                if let conference = theRoom.conference {
                    
                    // Check for added conference participant
                    for participant in conference.participants {
                        if !participants.contains(participant) {
                            participants.append(participant)
                            if participant.isMe() {
                                conferenceStatus.text = "Connected"
                            }
                        }
                    }
                    
                    // Check for removed conference participant
                    if let theRoomParticipants  = theRoom.conference?.participants {
                        for participant in participants {
                            if !theRoomParticipants.contains(participant) {
                                participants.removeAll { otherParticipant in
                                    participant.getContact().identifier == otherParticipant.getContact().identifier
                                }
                            }
                        }
                    }
                    
                    participantTableView.reloadData()
                }
            }
        }
    }
    
    // Call notification handlers
    
    @objc func didAddCall(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didAddCall(notification: notification)
            }
            return
        }
        
        if let rtcCall = notification.object as? RTCCall {
            NSLog("[ConferenceViewController] didAddCall status='\(Call.string(for: rtcCall.status) ?? "")' videoCall=\(videoCall)")
            if videoCall {
                ServicesManager.sharedInstance().rtcService.addVideoMedia(to: rtcCall)
            }
        }
    }
    
    @objc func didUpdateCall(notification : Notification) {
        if let rtcCall = notification.object as? RTCCall {
            NSLog("[ConferenceViewController] didUpdateCall status='\(Call.string(for: rtcCall.status) ?? "")'")
        }
    }
    
    @objc func didRemoveCall(notification : Notification) {
        NSLog("[ConferenceViewController] didRemoveCall")
    }
    
    // Local video notification handlers
    
    @objc func didAddCaptureSession(notification : Notification) {
        NSLog("[ConferenceViewController] didAddCaptureSession")
        
        if let captureSession = notification.object as? AVCaptureSession {
            self.cameraCaptureSession = captureSession
        }
    }
    
    @objc func didAddLocalVideoTrack(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didAddLocalVideoTrack(notification: notification)
            }
            return
        }
        
        NSLog("[ConferenceViewController] didAddLocalVideoTrack")
        
        guard let localVideoTrack = notification.object as? RTCVideoTrack else {
            return
        }
        
        if self.localVideoTrack == localVideoTrack {
            return
        }
        self.localVideoTrack = localVideoTrack
        
        if let localVideoView {
            localVideoView.videoContentMode = .scaleAspectFill
            localVideoTrack.add(localVideoView)
            localVideoView.isHidden = false
        }
    }
    
    @objc func didRemoveLocalVideoTrack(notification : Notification) {
        NSLog("[ConferenceViewController] didRemoveLocalVideoTrack")
        if let localVideoView {
            localVideoTrack?.remove(localVideoView)
            localVideoView.isHidden = true
        }
    }
    
    // Remote videos notification handlers
    
    @objc func didAddPublisher(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didAddPublisher(notification: notification)
            }
            return
        }
        
        guard let userInfo = notification.object as? NSDictionary,
              let confParticipant = userInfo.object(forKey: kConferenceParticipantKey) as? RoomConfParticipant,
              let room = userInfo.object(forKey: kRoomKey) as? Room,
              !confParticipant.isMe() else {
            return
        }
        
        NSLog("[ConferenceViewController] didAddPublisher")
        
        ServicesManager.sharedInstance().conferencesManagerService.updateVideoSubscription(forPublisher: confParticipant, room: room, streamLevel: .unknown)
    }
    
    @objc func didRemovePublisher(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didRemovePublisher(notification: notification)
            }
            return
        }
        
        guard let userInfo = notification.object as? NSDictionary,
              let confParticipant = userInfo.object(forKey: kConferenceParticipantKey) as? RoomConfParticipant,
              let room = userInfo.object(forKey: kRoomKey) as? Room,
              !confParticipant.isMe() else {
            return
        }
        
        NSLog("[ConferenceViewController] didRemovePublisher")
        
        ServicesManager.sharedInstance().conferencesManagerService.releaseVideoSubscription(forPublisher: confParticipant, room: room)
        
        if let publisherId = confParticipant.getRainbowId(),
           let videoView = self.remoteVideoViews[publisherId] {
            let videoTrack = ServicesManager.sharedInstance().rtcService.remoteVideoTrack(forPublisherRainbowID: publisherId)
            videoTrack?.remove(videoView)
            videoView.isHidden = true
        }
    }
    
    @objc func didAddRemoteVideoTrack(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didAddRemoteVideoTrack(notification: notification)
            }
            return
        }
        
        guard let userInfo = notification.object as? NSDictionary,
              let  publisherId = userInfo.object(forKey: "publisherId") as? String else {
            return
        }
        
        if let videoView = self.remoteVideoViews[publisherId],
           videoView.isHidden,
           let videoTrack = ServicesManager.sharedInstance().rtcService.remoteVideoTrack(forPublisherRainbowID: publisherId) {
            NSLog("[ConferenceViewController] didAddRemoteVideoTrack: publisherId=\(publisherId) videoTrack=\(String(describing: videoTrack))")
            videoView.videoContentMode = .scaleAspectFill
            videoTrack.add(videoView)
            videoView.isHidden = false
        }
    }
    
    @objc func didRemoveRemoteVideoTrack(notification : Notification) {
        guard let userInfo = notification.object as? NSDictionary,
              let  publisherId = userInfo.object(forKey: "publisherId") as? String else {
            return
        }
        
        NSLog("[ConferenceViewController] didRemoveRemoteVideoTrack: : publisherId=\(publisherId)")
    }
    
    // Microphone permission handlers
    
    @objc func didAllowMicrophone(notification : Notification) {
        NSLog("[ConferenceViewController] didAllowMicrophone")
    }
    
    @objc func didRefuseMicrophone(notification : Notification) {
        NSLog("[ConferenceViewController] didRefuseMicrophone")
    }
    
    // Mute/unmute notification handlers
    
    @objc func didReceiveUnmuteRequest(notification : Notification) {
        NSLog("[ConferenceViewController] didReceiveUnmuteRequest")
    }
    
    // MARK: - UITableViewDelegate protocol
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ConferenceTableViewCell {
            let participant = participants[indexPath.row]
            let contact = participant.getContact()
            cell.nameLabel.text = participant.getDisplayName()
            if let photoData = contact.photoData {
                cell.avatarImage.image = UIImage.init(data: photoData)
                cell.avatarImage.tintColor = UIColor.clear
            } else {
                cell.avatarImage.image = UIImage.init(named: "Default_Avatar")
                cell.avatarImage.tintColor = UIColor.init(hue: CGFloat(indexPath.row*36%100)/100.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            }
            if participant.isMe() {
                localVideoView = cell.videoView
            } else {
                remoteVideoViews[contact.identifier] = cell.videoView
            }
            cell.muteButton.tag = indexPath.row
            let image = participant.muted ? UIImage(systemName: "mic.slash.fill") : UIImage(systemName: "mic.fill")
            cell.muteButton.setImage(image, for: .normal)
        }
    }
    
    // MARK: - UITableViewDataSource protocol
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: participantCellIdentifier, for: indexPath)
        return cell
    }
    
    // MARK: - UIAction
    
    @IBAction func muteUmuteAction(_ sender: Any?) {
        if let button = sender as? UIButton {
            let participant = participants[button.tag]
            let newMuteState = !participant.muted
            
            if let room {
                ServicesManager.sharedInstance().conferencesManagerService.changeMuteParticipantState(room, conferenceParticipant: participant, muted: newMuteState) { error, askToUnmuteSuccess in
                    let image = newMuteState ? UIImage(systemName: "mic.slash.fill") : UIImage(systemName: "mic.fill")
                    DispatchQueue.main.async {
                        button.setImage(image, for: .normal)
                    }
                }
            }
        }
    }
}
