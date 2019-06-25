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

#import <UIKit/UIKit.h>
#import <Rainbow/Contact.h>

@interface DetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) Contact *contact;
@property (nonatomic, strong) UIImage *contactImage;
@property (nonatomic, strong) UIColor *contactImageTint;
@end
