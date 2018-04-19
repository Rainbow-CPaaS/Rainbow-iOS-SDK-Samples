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

@interface ChannelPayload : NSObject
/**
 *  The channel ID where the item was published
 */
@property (nonatomic, readonly) NSString *channelId;

/**
 *  The ID of the item
 */
@property (nonatomic, readonly) NSString *id;

/**
 *  The title of the item's payload
 */
@property (nonatomic, readonly) NSString *title;

/**
 *  The text message of the item's payload
 */
@property (nonatomic, readonly) NSString *message;

/**
 *  An optional URL of the item's payload
 */
@property (nonatomic, readonly) NSString *url;

@end
