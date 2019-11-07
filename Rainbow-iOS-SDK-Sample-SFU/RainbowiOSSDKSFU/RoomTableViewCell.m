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

#import "RoomTableViewCell.h"

@implementation RoomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _avatar.layer.masksToBounds = YES;
    _avatar.layer.cornerRadius = _avatar.frame.size.width/2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
