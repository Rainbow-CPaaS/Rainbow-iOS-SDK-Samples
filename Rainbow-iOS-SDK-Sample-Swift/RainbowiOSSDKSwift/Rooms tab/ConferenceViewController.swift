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

class ListItem {
    var conferenceParticipant : ConferenceParticipant?
    var cell : ConferenceTableViewCell?
    
    init(conferenceParticipant: ConferenceParticipant? = nil, cell: ConferenceTableViewCell? = nil) {
        self.conferenceParticipant = conferenceParticipant
        self.cell = cell
    }
}

class ConferenceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // The room where the conference is running
    var room : Room?
    // true if we start or join the conference with local video on
    var videoCall = false
    
    @IBOutlet weak var conferenceStatus: UILabel!
    @IBOutlet weak var participantTableView: UITableView!
    
    // The conference participant including the connected user
    private var participants : [ListItem] = []
    
    // Conference publisher not including the connected user
    private var publishers : [RoomConfParticipant] = []
    // RTCMTLVideoView for displaying the local and remote videos
    private var videoViews: [String:RTCMTLVideoView] = [:]

    private var myParticipantId : String?
    private var localVideoTrack : RTCVideoTrack?
    private var isDismissing = false
    private let participantCellIdentifier = "ConferenceParticipantCell"
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listen to update conference notification
        NotificationCenter.default.addObserver(self, selector:#selector(didUpdateConference(notification:)), name:NSNotification.Name(kConferencesManagerDidUpdateConference), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(participantHasJoined(notification:)), name:NSNotification.Name(kConferencesManagerParticipantHasJoined), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(participantHasLeft(notification:)), name:NSNotification.Name(kConferencesManagerParticipantHasLeft), object:nil)
        
        // WebRTC audio call handling
        NotificationCenter.default.addObserver(self, selector:#selector(didAddCall(notification:)), name:NSNotification.Name(kTelephonyServiceDidAddCall), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didUpdateCall(notification:)), name:NSNotification.Name(kTelephonyServiceDidUpdateCall), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRemoveCall(notification:)), name:NSNotification.Name(kTelephonyServiceDidRemoveCall), object: nil)
        
        // Local video notifications
        NotificationCenter.default.addObserver(self, selector:#selector(didAddLocalVideoTrack(notification:)), name:NSNotification.Name(kRTCServiceDidAddLocalVideoTrack), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRemoveLocalVideoTrack(notification:)), name:NSNotification.Name(kRTCServiceDidRemoveLocalVideoTrack), object: nil)
        
        // Remote video notifications
        NotificationCenter.default.addObserver(self, selector: #selector(didAddRemoteVideoTrack(notification:)), name: NSNotification.Name(kRTCServiceDidAddRemoteVideoTrack), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveRemoteVideoTrack(notification:)), name: NSNotification.Name(kRTCServiceDidRemoveRemoteVideoTrack), object: nil)
        
        // Publisher notifications
        NotificationCenter.default.addObserver(self, selector: #selector(didAddPublisher(notification:)), name: NSNotification.Name(kConferencesManagerDidAddPublisher), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemovePublisher(notification:)), name: NSNotification.Name(kConferencesManagerDidRemovePublisher), object: nil)
        
        // Microphone notifications
        NotificationCenter.default.addObserver(self, selector:#selector(didAllowMicrophone(notification:)), name:NSNotification.Name(kRTCServiceDidAllowMicrophone), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRefuseMicrophone(notification:)), name:NSNotification.Name(kRTCServiceDidRefuseMicrophone), object: nil)
        
        // Unmute request notifications
        NotificationCenter.default.addObserver(self, selector:#selector(didReceiveUnmuteRequest(notification:)), name:NSNotification.Name(kConferencesManagerDidReceiveUnmuteRequest), object: nil)
        
        participantTableView.delegate = self
        participantTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let conference = room?.conference, conference.isConnectedState() {
            conferenceStatus.text = "Connected"
            resyncParticipants(in: conference)
        }
    }
    
    // MARK: - Segue navigation
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil, let room = room {
            NSLog("[ConferenceViewController] dismiss viewcontroller")
            
            if let conference = room.conference, conference.isConnectedState() {
                // Allow some time after back is pressed before doing the hangup
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // Terminate the conference when the back button is pressed
                    NSLog("[ConferenceViewController] hangup conference")
                    ServicesManager.sharedInstance().conferencesManagerService.hangup(room) {
                        error in
                        if let error = error as? NSError {
                            NSLog("Error: ", error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Conference notification handlers
    
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            // Handle conference participant being added, updated or removed
            if changedAttributes.contains("participants"),
               let conference = theRoom.conference {
                NSLog("[ConferenceViewController] didUpdateConference: participants: \(conference.participants)")
                resyncParticipants(in: conference)
            }
        }
    }
    
    // Resync the participants array with added/removed participants in the conference
    func resyncParticipants(in conference : Conference) {
        // Check for added conference participant
        for participant in conference.participants {
            if !participants.contains(where: { listItem in listItem.conferenceParticipant == participant }) {
                let cell = Bundle.main.loadNibNamed("ConferenceTableViewCell", owner: self, options: nil)?[0] as? ConferenceTableViewCell
                participants.append(ListItem(conferenceParticipant: participant, cell: cell))
                if participant.isMe() {
                    myParticipantId = participant.getContact().identifier
                    conferenceStatus.text = "Connected"
                }
            }
        }
        
        // Check for removed conference participant
        for listItem in participants {
            if let conferenceParticipant = listItem.conferenceParticipant,
               !conference.participants.contains(conferenceParticipant) {
                participants.removeAll { listItem in
                    conferenceParticipant.getContact().identifier == listItem.conferenceParticipant?.getContact().identifier
                }
            }
        }
        
        participantTableView.reloadData()
    }
    
    @objc func participantHasJoined(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.participantHasJoined(notification: notification)
            }
            return
        }
        
        if let dict = notification.object as? Dictionary<String, Any>,
           let conferenceParticipant = dict[kConferenceParticipantKey] as? ConferenceParticipant {
            NSLog("[ConferenceViewController] participantHasJoined: name='\(conferenceParticipant.getDisplayName())'")
        }
    }
    
    @objc func participantHasLeft(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.participantHasLeft(notification: notification)
            }
            return
        }
        
        if let dict = notification.object as? Dictionary<String, Any>,
           let conferenceParticipant = dict[kConferenceParticipantKey] as? ConferenceParticipant {
            NSLog("[ConferenceViewController] participantHasLeft: name='\(conferenceParticipant.getDisplayName())'")
        }
    }
    // MARK: -  Call notification handlers
    
    @objc func didAddCall(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didAddCall(notification: notification)
            }
            return
        }
        
        if let rtcCall = notification.object as? RTCCall {
            NSLog("[ConferenceViewController] didAddCall status='\(Call.string(for: rtcCall.status) ?? "")' videoCall=\(videoCall)")
            if videoCall && rtcCall.canAddVideo() && !rtcCall.isLocalVideoEnabled() {
                ServicesManager.sharedInstance().rtcService.addVideoMedia(to: rtcCall)
            }
        }
    }
    
    @objc func didUpdateCall(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didUpdateCall(notification: notification)
            }
            return
        }
        if let rtcCall = notification.object as? RTCCall {
            NSLog("[ConferenceViewController] didUpdateCall status='\(Call.string(for: rtcCall.status) ?? "")'")
            
            if rtcCall.status == .established, let conference = room?.conference, !conference.isOwner() {
                resyncParticipants(in: conference)
            }
        }
    }
    
    @objc func didRemoveCall(notification : Notification) {
        NSLog("[ConferenceViewController] didRemoveCall")
    }
    
    // MARK: - Local video notification handlers
    
    @objc func didAddLocalVideoTrack(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didAddLocalVideoTrack(notification: notification)
            }
            return
        }
        
        guard let localVideoTrack = notification.object as? RTCVideoTrack, 
            self.localVideoTrack != localVideoTrack else {
            return
        }
        NSLog("[ConferenceViewController] didAddLocalVideoTrack")
        self.localVideoTrack = localVideoTrack
        
        if let participantId = myParticipantId, let localVideoView = videoViews[participantId] {
            localVideoView.videoContentMode = .scaleAspectFill
            localVideoTrack.add(localVideoView)
            localVideoView.isHidden = false
        }
    }
    
    @objc func didRemoveLocalVideoTrack(notification : Notification) {
        NSLog("[ConferenceViewController] didRemoveLocalVideoTrack")
        if let participantId = myParticipantId, let localVideoView = videoViews[participantId] {
            localVideoTrack?.remove(localVideoView)
            localVideoView.isHidden = true
        }
    }
    
    // MARK: - publisher notification handlers
    
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
              let publisherId = confParticipant.getRainbowId(),
              !publishers.contains(confParticipant),
              !confParticipant.isMe() else {
            return
        }
        
        NSLog("[ConferenceViewController] didAddPublisher publisherID=\(publisherId)")
        publishers.append(confParticipant)
        
        ServicesManager.sharedInstance().conferencesManagerService.updateDisplayedVideos(room, level: .low, publishers: publishers)
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
              let publisherId = confParticipant.getRainbowId(),
              publishers.contains(confParticipant),
              !confParticipant.isMe() else {
            return
        }
        
        NSLog("[ConferenceViewController] didRemovePublisher publisherID=\(publisherId)")
        
        publishers.removeAll(where: { confParticipant in confParticipant.getRainbowId() == publisherId })
        ServicesManager.sharedInstance().conferencesManagerService.updateDisplayedVideos(room, level: .low, publishers: publishers)
    }
    
    // MARK: - Remote videos notification handlers
    
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
        
        if let videoView = self.videoViews[publisherId],
           videoView.isHidden,
           let videoTrack = ServicesManager.sharedInstance().rtcService.remoteVideoTrack(forPublisherRainbowID: publisherId) {
            NSLog("[ConferenceViewController] didAddRemoteVideoTrack: publisherId=\(publisherId) videoTrack=\(String(describing: videoTrack))")
            videoView.videoContentMode = .scaleAspectFill
            videoView.renderFrame(nil)
            videoTrack.add(videoView)
            videoView.isHidden = false
        }
    }
    
    @objc func didRemoveRemoteVideoTrack(notification : Notification) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didRemoveRemoteVideoTrack(notification: notification)
            }
            return
        }
        
        guard let userInfo = notification.object as? NSDictionary,
              let  publisherId = userInfo.object(forKey: "publisherId") as? String else {
            return
        }
        
        if let videoView = self.videoViews[publisherId],
           !videoView.isHidden {
            NSLog("[ConferenceViewController] didRemoveRemoteVideoTrack: publisherId=\(publisherId))")
            videoView.renderFrame(nil)
            videoView.isHidden = true
        }
    }
    
    // MARK: - Microphone permission handlers
    
    @objc func didAllowMicrophone(notification : Notification) {
        NSLog("[ConferenceViewController] didAllowMicrophone")
    }
    
    @objc func didRefuseMicrophone(notification : Notification) {
        NSLog("[ConferenceViewController] didRefuseMicrophone")
    }
    
    // MARK: - Mute/unmute notification handlers
    
    @objc func didReceiveUnmuteRequest(notification : Notification) {
        NSLog("[ConferenceViewController] didReceiveUnmuteRequest")
        
        guard let infos = notification.object as? Dictionary<String,Any>,
              let room = infos[kRoomKey] as? Room else {
            NSLog("[ConferenceViewController] didReceiveUnmuteRequest error: missing parameter")
            return
        }
        
        guard let myParticipant = room.conference?.getMyParticipant() else {
            NSLog("[ConferenceViewController] didReceiveUnmuteRequest error: missing myParticipant")
            return
        }
        
        // Do the unmute
        ServicesManager.sharedInstance().conferencesManagerService.changeMuteParticipantState(room, conferenceParticipant: myParticipant, muted: false)
    }
    
    // MARK: - UITableViewDelegate protocol
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UITableViewDataSource protocol
    
    // We don't use tableView.dequeueReusableCell() because it doesn't guarantee that we'll get the same cell
    // with the good VideoView for the conference participant.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if participants.count > indexPath.row,
            let cell = participants[indexPath.row].cell {
            configure(cell: cell, for: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    func configure(cell : ConferenceTableViewCell, for indexPath: IndexPath) {
        if let participant = participants[indexPath.row].conferenceParticipant {
            let contact = participant.getContact()
            cell.nameLabel.text = participant.getDisplayName()
            if let photoData = contact.photoData {
                cell.avatarImage.image = UIImage.init(data: photoData)
                cell.avatarImage.tintColor = UIColor.clear
            } else {
                cell.avatarImage.image = UIImage.init(named: "Default_Avatar")
                cell.avatarImage.tintColor = UIColor.init(hue: CGFloat(indexPath.row*36%100)/100.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            }
            videoViews[contact.identifier] = cell.videoView
            cell.muteButton.tag = indexPath.row
            let image = participant.muted ? UIImage(systemName: "mic.slash.fill") : UIImage(systemName: "mic.fill")
            cell.muteButton.setImage(image, for: .normal)
        }
    }
    
    // MARK: - UIAction
    
    @IBAction func muteUmuteAction(_ sender: Any?) {
        if let button = sender as? UIButton,
           let myParticipant = room?.conference?.getMyParticipant(),
           let participant = participants[button.tag].conferenceParticipant, participant.isMe() || myParticipant.role == .moderator {
            
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
