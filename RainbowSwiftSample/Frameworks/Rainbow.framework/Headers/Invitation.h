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
#import "Peer.h"


/**
 *  The different invitations statuses
 */
typedef NS_ENUM(NSInteger, InvitationStatus) {
    /**
     *  Invitation is pending (not yet responded)
     */
    InvitationStatusPending = 1,
    /**
     *  Invitation has been accepted
     */
    InvitationStatusAccepted,
    /**
     *  Invitation has been auto-accepted due to users in same company
     */
    InvitationStatusAutoAccepted,
    /**
     *  Invitation has been declined
     */
    InvitationStatusDeclined,
    /**
     *  Invitation has been deleted (by us on another device)
     */
    InvitationStatusDeleted,
    /**
     *  Invitation has been canceled (by owner of this invitation)
     */
    InvitationStatusCanceled,
    /**
     *  Invitation has failed (bad eMail,...)
     */
    InvitationStatusFailed
};

/**
 *  The different invitations directions
 */
typedef NS_ENUM(NSInteger, InvitationDirection) {
    /**
     *  Received invitation. Somebody is inviting me
     */
    InvitationDirectionReceived = 1,
    /**
     *  Sent invitation. I invited somebody
     */
    InvitationDirectionSent
};


@interface Invitation : NSObject


@property (nonatomic, readonly) NSString *invitationID;

/**
 *  Direction of the invitation.
 *  Whether it's a sent or received invitation
 */
@property (nonatomic, readonly) InvitationDirection direction;

/**
 *  The email which invited me or I have invited
 */
@property (nonatomic, readonly) NSString *email;

/**
 *  The phone number which I have invited
 */
@property (nonatomic, readonly) NSString *phoneNumber;

/**
 *  The peer which have invited me or I invited
 *  NB : This might be _nil_ if it's a newly
 *  sent invitation to a non-yet rainbow email address for example
 *
 *  This might not be populated if the status is pending
 *  But should be populated for any other statuses
 */
@property (nonatomic, readonly) Peer *peer;

/**
 *  Current status of the invitation
 */
@property (nonatomic, readonly) InvitationStatus status;

/**
 *  Date when the invitation was launched
 */
@property (nonatomic, readonly) NSDate *date;

/**
 *  Convert a direction to a printable string
 *
 *  @param direction The invitation direction
 *
 *  @return String of the invitation direction
 */
+(NSString *) stringFromInvitationDirection:(InvitationDirection) direction;

/**
 *  Convert a string to an InvitationDirection enum value (if possible)
 *
 *  @param direction The invitation direction as string. Allowed values are "sent" and "received"
 *
 *  @return The invitation direction as enum
 */
+(InvitationDirection) invitationDirectionFromString:(NSString *) direction;

/**
 *  Convert a status to a printable string
 *
 *  @param status The invitation status
 *
 *  @return String of the invitation status
 */
+(NSString *) stringFromInvitationStatus:(InvitationStatus) status;

/**
 *  Convert a string to an InvitationStatus enum value (if possible)
 *
 *  @param direction The invitation status as string. Allowed values are "pending", "accepted", "auto-accepted" and "declined"
 *
 *  @return The invitation status as enum
 */
+(InvitationStatus) invitationStatusFromString:(NSString *) status;

@end
