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
/**
 *  Peer object
 */
@interface Peer : NSObject
/** Rainbow ID */
@property (nonatomic, readonly) NSString *rainbowID;
/** User jid */
@property (nonatomic, readonly) NSString *jid;
/** User display name */
@property (nonatomic, readonly) NSString *displayName;

/** jid to use for rtc calls (jid of the user for peer of contact kind, conference jid for room object kind) */
@property (nonatomic, readonly) NSString *rtcJid;
@end
