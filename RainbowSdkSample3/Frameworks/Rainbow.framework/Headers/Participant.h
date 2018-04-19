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
#import "Contact.h"

/**
 *  Participant Status
 */
typedef NS_ENUM(NSInteger, ParticipantStatus) {
    /**
     *  Participant status unknown
     */
    ParticipantStatusUnknown = 0,
    /**
     *  Participant is invited, he doesn't accept yet the invitation
     */
    ParticipantStatusInvited,
    /**
     *  Participant has rejected the invitation, he doesn't receive messages
     */
    ParticipantStatusRejected,
    /**
     *  Participant has accepted the invitation, he can see messages sent
     */
    ParticipantStatusAccepted,
    /**
     *  Participant has unsubscribed, he will not be notified of new messages he can still see messages
     */
    ParticipantStatusUnsubscribed,
    /**
     *  Participant is no more present
     */
    ParticipantStatusDeleted
};
/**
 *  Participant privilege
 */
typedef NS_ENUM(NSInteger, ParticipantPrivilege) {
    /**
     *  Privilege unknown
     */
    ParticipantPrivilegeUnknown = 0,
    /**
     * Participant is the owner of the room
     */
    ParticipantPrivilegeOwner,
    /**
     *  Participant is a standart user, he can sent messages
     */
    ParticipantPrivilegeUser,
    /**
     *  Participant is a moderator, he can administrate the room
     */
    ParticipantPrivilegeModerator,
    /**
     *  Particiapant is a guest
     */
    ParticipantPrivilegeGuest
};
/**
 *  Participant object
 */
@interface Participant : NSObject

/**
 *  Contact that represent the participant
 *  @see Contact
 */
@property (nonatomic, readonly) Contact *contact;

/**
 *  Participant privilege
 *  @see ParticipantPrivilege
 */
@property (nonatomic, readonly) ParticipantPrivilege privilege;

/**
 *  Participant status
 *  @see ParticipantStatus
 */
@property (nonatomic, readonly) ParticipantStatus status;

/**
 *  Participant addition date
 */
@property (nonatomic, readonly) NSDate *addedDate;

@end
