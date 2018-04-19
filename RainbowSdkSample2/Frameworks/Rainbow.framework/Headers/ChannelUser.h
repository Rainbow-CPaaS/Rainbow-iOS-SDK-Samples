/*
 * Rainbow
 *
 * Copyright (c) 2016, ALE International
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
#import "Channel.h"

@interface ChannelUser : NSObject
/**
 *  The Rainbow ID of the user
 */
@property (nonatomic, readonly) NSString *rainbowId;

/**
 *  The role of the user in the channel :
 *    ChannelUserTypeNone      : the user is retired from the channel
 *    ChannelUserTypeMember    : the user is a read-only member in the channel
 *    ChannelUserTypePublisher : The user is a publisher in the channel
 *    ChannelUserTypeOwner     : The user is the owner of the channel
 */
@property (nonatomic, readonly) ChannelUserType type;

/**
 *  The date the user was added to the channel
 */
@property (nonatomic, readonly) NSDate *additionDate;

/**
 *  The user's login email
 */
@property (nonatomic, readonly) NSString *loginEmail;

/**
 *  the user's display name
 */
@property (nonatomic, readonly) NSString *displayName;

/**
 *  the user's company ID
 */
@property (nonatomic, readonly) NSString *companyId;

/**
 *  the user's company name
 */
@property (nonatomic, readonly) NSString *companyName;

@end
