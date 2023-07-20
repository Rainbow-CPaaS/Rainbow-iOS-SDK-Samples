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

class ConversationsTableViewCell: UITableViewCell {
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var peerName: UILabel!
    @IBOutlet weak var badgeValue: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.badgeValue.layer.cornerRadius = self.badgeValue.frame.size.width/2
        self.badgeValue.layer.masksToBounds = true
    }
}
