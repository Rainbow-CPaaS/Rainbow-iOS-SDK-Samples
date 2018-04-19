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
#import "ChannelPayload.h"

/**
 *  The channel visibility
 */
typedef NS_ENUM(NSInteger, ChannelVisibility) {
    /**
     * The channel is public
     */
    ChannelVisibilityPublic = 0,
    /**
     *  The channel is restricted to the company
     */
    ChannelVisibilityCompany,
    /**
     *  The channel is private
     */
    ChannelVisibilityPrivate
};

/**
 *  The channel user Type
 */
typedef NS_ENUM(NSInteger, ChannelUserType) {
    /**
     * The user has no role in the channel
     */
    ChannelUserTypeNone = 0,
    /**
     *  The user is a member of the channel
     */
    ChannelUserTypeMember,
    /**
     *  The user is a publisher in the channel
     */
    ChannelUserTypePublisher,
    /**
     *  The user is the owner of the channel
     */
    ChannelUserTypeOwner
};

@interface Channel : NSObject
/**
 *  The channel name
 */
@property (nonatomic, readonly) NSString *name;

/**
 *  The channel topic
 */
@property (nonatomic, readonly) NSString *topic;

/**
 *  The channel visibility between ChannelVisibilityPublic, ChannelVisibilityCompany, ChannelVisibilityPrivate
 */
@property (nonatomic, readonly) ChannelVisibility visibility;

/**
 *  The channel maximum item count, when reached the oldest published one is retracted and a notification is
 *  sent.
 */
@property (nonatomic, readonly) int maxItems;

/**
 *  The channel maximum payload size
 */
@property (nonatomic, readonly) int maxPayloadSize;

/**
 *  The channel ID
 */
@property (nonatomic, readonly) NSString *id;

/**
 *  The company ID of the owner of the channel
 */
@property (nonatomic, readonly) NSString *companyId;

/**
 *  The creator ID
 */
@property (nonatomic, readonly) NSString *creatorId;

/**
 *  The creation date of the channel
 */
@property (nonatomic, readonly) NSDate *creationDate;

/**
 *  The current subscribed user count
 */
@property (nonatomic, readonly) int usersCount;

/**
 *  The array of published items in the channel
 */
@property (nonatomic, readonly) NSArray<ChannelPayload *> *items;

-(void)addOrUpdateItem:(ChannelPayload *)item;
-(void)removeItem:(ChannelPayload *)item;

@end
