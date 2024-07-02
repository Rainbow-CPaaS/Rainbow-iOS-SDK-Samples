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

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // notifications related to calls
        NotificationCenter.default.addObserver(self, selector: #selector(didAddCall(notification:)),  name:NSNotification.Name(kTelephonyServiceDidAddCall), object:nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    @objc func didAddCall(notification : Notification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didAddCall(notification: notification)
            }
            return
        }
        
        if let rtcCall = notification.object as? RTCCall,
            let peer = rtcCall.remoteParty as? PeerProtocol,
           let peerId = peer.rainbowID,
           let conversation = ServicesManager.sharedInstance().conversationsManagerService.getConversationWithPeerID(peerId ?? ""),
           let room = conversation.peer as? Room {
            NSLog("[TabBarController] didAddCall: is incoming=\(rtcCall.isIncoming), is a conference call=\(rtcCall.isRtcSfuCall) in room='\(room.displayName ?? "")'")
            
        } else {
            NSLog("[TabBarController] didAddCall: not a WebRTC call")
        }
    }
    
}
