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
    @IBOutlet weak var localVideoView : RTCMTLVideoView!

    private let participantCellIdentifier = "ConferenceParticipantCell"
    private var participants : [ConferenceParticipant] = []
    
    private var cameraCaptureSession : AVCaptureSession?
    private var localVideoTrack : RTCVideoTrack?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localVideoView.isHidden = true
        
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
        NotificationCenter.default.addObserver(self, selector:#selector(didAddRemoteVideoTrack(notification:)), name:NSNotification.Name(kRTCServiceDidAddRemoteVideoTrack), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRemoveRemoteVideoTrack(notification:)), name:NSNotification.Name(kRTCServiceDidRemoveRemoteVideoTrack), object: nil)
        // Microphone notifications
        NotificationCenter.default.addObserver(self, selector:#selector(didAllowMicrophone(notification:)), name:NSNotification.Name(kRTCServiceDidAllowMicrophone), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRefuseMicrophone(notification:)), name:NSNotification.Name(kRTCServiceDidRefuseMicrophone), object: nil)
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
        
        localVideoView.videoContentMode = .scaleAspectFill
        localVideoView.clipsToBounds = true
        localVideoTrack.add(localVideoView)
        localVideoView.isHidden = false
    }
    
    @objc func didRemoveLocalVideoTrack(notification : Notification) {
        NSLog("[ConferenceViewController] didRemoveLocalVideoTrack")
        localVideoTrack?.remove(localVideoView)
        localVideoView.isHidden = true
    }
    
    
    // Remote videos notification handlers
    
    @objc func didAddRemoteVideoTrack(notification : Notification) {
        NSLog("[ConferenceViewController] didAddRemoteVideoTrack")
    }
    
    @objc func didRemoveRemoteVideoTrack(notification : Notification) {
        NSLog("[ConferenceViewController] didRemoveRemoteVideoTrack")
    }
    
    // Microphone permission handlers
    
    @objc func didAllowMicrophone(notification : Notification) {
        NSLog("[ConferenceViewController] didAllowMicrophone")
    }
    
    @objc func didRefuseMicrophone(notification : Notification) {
        NSLog("[ConferenceViewController] didRefuseMicrophone")
    }
    
    // MARK: - UITableViewDelegate protocol
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UITableViewDataSource protocol
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: participantCellIdentifier)
        let participant = participants[indexPath.row]
        cell.textLabel?.text = participant.getDisplayName()
        return cell
    }

}
