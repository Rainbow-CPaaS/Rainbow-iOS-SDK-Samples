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

#define kContactPresenceKey @"presence"
/**
 *  Contact presence type
 */
typedef NS_ENUM(NSInteger, ContactPresence) {
    /**
     *  Unavailable
     */
    ContactPresenceUnavailable = 0,
    /**
     *  Available
     */
    ContactPresenceAvailable,
    /**
     *  Dot not disturb
     */
    ContactPresenceDoNotDisturb,
    /**
     *  Busy
     */
    ContactPresenceBusy,
    /**
     *  Away
     */
    ContactPresenceAway,
    /**
     *  Invisible
     */
    ContactPresenceInvisible
};

/**
 *  Presence object
 */
@interface Presence : NSObject

/** Presence status */
@property (nonatomic, readonly) NSString *status;
/**
 *  Contact presence
 *  @see ContactPresence
 */
@property (nonatomic, readonly) ContactPresence presence;
/**
 *  Transform a Presence object into string
 *
 *  @param presence presence object to tranform
 *
 *  @return String value that represent the given presence
 */
+(NSString *) stringForContactPresence:(Presence*) presence;

/**
 *  Helper to create easly a presence available object
 *
 *  @return Presence available object
 */
+(Presence *) presenceAvailable;

/**
 *  Helper to create easly a presence Do not disturb object
 *
 *  @return Presence Do not distrub object
 */
+(Presence *) presenceDoNotDistrub;

/**
 *  Helper to create easly a presence away object
 *
 *  @return Presence away object
 */
+(Presence *) presenceAway;

/**
 *  Helper to create easly a presence extended away (invisible) object
 *
 *  @return Presence extended away (invisible) object
 */
+(Presence *) presenceExtendedAway;

+(Presence *) presenceUnavailable;

@end
