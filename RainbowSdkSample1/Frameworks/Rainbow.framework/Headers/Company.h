/*
 * Rainbow
 *
 * Copyright (c) 2017, ALE International
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

#import <Foundation/Foundation.h>

@class Contact;

@interface Company : NSObject
@property (readonly) NSString *name;
@property (readonly) NSString *country;
@property (readonly) NSData *logo;
@property (readonly) NSData *banner;
@property (readonly) NSString *websiteURL;
@property (readonly) NSString *supportEmail;
@property (readonly) NSString *companyDescription;
@property (readonly) NSString *companySize;
@property (readonly) NSString *slogan;
@property (readonly) NSDate *lastAvatarUpdateDate;
@property (readonly) NSDate *lastBannerUpdateDate;
@property (readonly) NSString *adminEmail;
@property (readonly) NSString *economicActivityClassification;
@property (readonly) Contact *companyContact;
@property (readonly) BOOL alreadyRequestToJoin;
@property (readonly) BOOL logoIsCircle;
@end
