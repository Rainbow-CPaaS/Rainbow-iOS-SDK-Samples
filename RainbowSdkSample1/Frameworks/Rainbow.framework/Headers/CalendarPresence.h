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

#define kCalendarPresenceKey @"calpresence"
/**
 *  Calendar presence type
 */
typedef NS_ENUM(NSInteger, ContactCalendarPresence) {
    /**
     *  Unavailable
     */
    CalendarPresenceUnavailable = 0,
    /**
     *  Available
     */
    CalendarPresenceAvailable,
    /**
     *  Busy
     */
    CalendarPresenceBusy,
    /**
     *  OutOfOffice
     */
    CalendarPresenceOutOfOffice
};

@interface CalendarAutomaticReply : NSObject

/** Message */
@property (nonatomic, readonly) NSString *message;

/** Message */
@property (nonatomic, readonly) NSDate *untilDate;

/** Is Automatic replay enabled */
@property (nonatomic, readonly) BOOL isEnabled;

/** Last date update has been done */
@property (nonatomic, readonly) NSDate *lastUpdateDate;

@end


/**
 *  Presence object
 */
@interface CalendarPresence : NSObject

/** Presence status */
@property (nonatomic, readonly) NSString *status;
/**
 *  ContactCalendarPresence presence
 *  @see ContactCalendarPresence
 */
@property (nonatomic, readonly) ContactCalendarPresence presence;
/**
 *  NSDate until
 */
@property (nonatomic, readonly) NSDate *until;

/**
 *  CalendarAutomaticReply automaticReply
 */
@property (nonatomic, readonly) CalendarAutomaticReply *automaticReply;

/**
 *  Transform a CalendarPresence object into string
 *
 *  @param presence presence object to tranform
 *
 *  @return String value that represent the given presence
 */
+(NSString *) stringForCalendarPresence:(CalendarPresence*) presence;

/**
 *  Helper to create easly a calendar presence available object
 *
 *  @return CalendarPresence available object
 */
+(CalendarPresence *) presenceAvailable;

/**
 *  Helper to create easly a calendar presence busy object
 *
 *  @return CalendarPresence busy object
 */
+(CalendarPresence *) presenceBusy;

/**
 *  Helper to create easly a calendar presence out of office object
 *
 *  @return CalendarPresence out of office object
 */
+(CalendarPresence *) presenceOutOfOffice;

@end
