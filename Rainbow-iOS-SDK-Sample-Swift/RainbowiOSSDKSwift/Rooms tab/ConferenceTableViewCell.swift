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
import WebRTC

class ConferenceTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var videoView: RTCMTLVideoView!
    @IBOutlet weak var muteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.isHidden = false
        videoView.isHidden = true
    }
    
}
