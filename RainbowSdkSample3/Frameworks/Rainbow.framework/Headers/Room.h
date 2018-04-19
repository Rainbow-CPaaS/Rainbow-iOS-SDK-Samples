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
#import "Participant.h"
#import "Conference.h"

#define kRoomParticipantsKey @"participants"
/**
 *  Room visibility
 */
typedef NS_ENUM(NSInteger, RoomVisibility) {
    /**
     *  Room is private, only invited people can found it
     */
    RoomVisibilityPrivate = 0,
    /**
     *  Room is public, everyone is able to found it
     */
    RoomVisibilityPublic
};
/**
 *  Room
 */
@interface Room : Peer
/**
 *  Room topic
 *  
 *  Optional field
 */
@property (nonatomic, readonly) NSString *topic;

/**
 *  Room visibility
 */
@property (nonatomic, readonly) RoomVisibility visibility;

/**
 *  All participants of this room, creator included
 */
@property (nonatomic, readonly) NSArray<Participant*> *participants;

/**
 *  Room owner
 */
@property (nonatomic, readonly) Contact *creator;

/**
 *  Room creation date
 */
@property (nonatomic, readonly) NSDate *creationDate;

/**
 *  @return `YES` if this room has been created by the logged user
 */
@property (nonatomic, readonly) BOOL isMyRoom;

/**
 *  @return `YES` if this room can be moderated by the logged user
 */
@property (nonatomic, readonly) BOOL isAdmin;

/**
 *  My Status in this room (easy accessor)
 */
@property (nonatomic, readonly) ParticipantStatus myStatusInRoom;

/**
 * The custom avatar
 */
@property (nonatomic, readonly) NSData *photoData;

/**
 *  The custom avatar last update date
 */
@property (nonatomic, readonly) NSDate *lastAvatarUpdateDate;

/**
 *  The custom data
 */
@property (nonatomic, readonly) NSDictionary *customData;

/**
 *  Conference associated to the room. Can be nil if there is no conference associated
 */
@property (nonatomic, readonly) Conference *conference;

/**
 *  Return the participant corresponding to the given contact
 *
 *  @param contact contact that must match into the participant list
 *
 *  @return the participant that match, return `nil` if not found
 */
-(Participant *) participantFromContact:(Contact *) contact;

@end

