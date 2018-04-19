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
#import "Room.h"
#import "Contact.h"

FOUNDATION_EXPORT NSString *const kRoomKey;
FOUNDATION_EXPORT NSString *const kRoomChangedAttributesKey;

FOUNDATION_EXPORT NSString *const kRoomsServiceDidAddRoom;
FOUNDATION_EXPORT NSString *const kRoomsServiceDidUpdateRoom;
FOUNDATION_EXPORT NSString *const kRoomsServiceDidRemoveRoom;
FOUNDATION_EXPORT NSString *const kRoomsServiceDidRemoveAllRooms;
FOUNDATION_EXPORT NSString *const kRoomsServiceDidReceiveRoomInvitation;
FOUNDATION_EXPORT NSString *const kRoomsServiceDidRoomInvitationStatusChanged;

typedef void (^RoomsServiceAttachConferenceCompletionHandler) (NSError *error, Conference *conference);
typedef void (^RoomsServiceDetachConferenceCompletionHandler) (NSError *error);
typedef void (^RoomsServiceManageCustomDataCompletionHandler) (NSError *error);
typedef void (^RoomsServiceMCompletionHandler) (NSDictionary *data, NSError *error);
typedef void (^RoomsServiceConferenceInvitationsCompletionHandler) (NSDictionary *response, NSError *error);
typedef void (^RoomsServiceConferenceCompletionHandler) (NSDictionary *conferenceData, NSError *error);
typedef void (^RoomsServiceConferencesCompletionHandler) (NSArray *conferencesData, NSError *error);
typedef void (^RoomsServiceUsersCompletionHandler) (NSArray<Participant *> *participants, NSError *error);

/**
 *  Manage multi user chat rooms
 */
@interface RoomsService : NSObject
/** @name RoomsService properties */

/**
 *  All rooms managed by Rooms Service
 */
@property (nonatomic, readonly) NSArray<Room *> *rooms;

/** @name RoomsService public methods */
/**
 *  Find a room based on it's unique identifer
 *
 *  @param jid room unique identifier
 *
 *  @return room that match the given unique identifier. Return `nil` if this room doesn't exists.
 */
-(Room*) getRoomByJid:(NSString *) jid;

/**
 *  Create a new Room
 *  This will send a request to the server to create the room.
 *
 *  Synchronous method ! Must not be invoked on MainThread
 *
 *  @param name  The room name
 *  @param topic The room topic (Optional)
 *
 *  @return The newly created room object
 */
-(Room *) createRoom:(NSString *) name withTopic:(NSString *) topic;

/**
 *  Invite a contact to join the given room
 *  Only creator can invite people to join a room
 *
 *  Synchronous method ! Must not be invoked on MainThread
 *
 *  @param contact the contact to invite to join
 *  @param room    the room to join
 */
-(void) inviteContact:(Contact *) contact inRoom:(Room *) room;

/**
 *  Cancel an invitation sent to a contact
 *  The contact must not have accept the invitation
 *
 *  @param contact the contact for which we must cancel the invitations
 *  @param room    the room where the given contact is invited
 */
-(void) cancelInvitationForContact:(Contact *) contact inRoom:(Room *) room;

/**
 *  Accept the invitation in the given room.
 *  This will trigger a kRoomsServiceDidRoomInvitationStatusChanged notification once done.
 *
 *  @param room The room to join.
 */
-(void) acceptInvitation:(Room *) room;

/**
 *  Decline the invitation in the given room and ignore it.
 *  This will trigger a kRoomsServiceDidRoomInvitationStatusChanged notification once done.
 *
 *  @param room The room to ignore.
 */
-(void) declineInvitation:(Room *) room;

/**
 *  This gives the number of not hosting conference room invitation still pending.
 *
 *  @return Number of invited status in rooms.
 */
-(NSUInteger) numberOfPendingRoomInvitations;

/**
 *  This gives the number of hosting conference room invitation still pending.
 *
 *  @return Number of invited status in rooms.
 */
-(NSUInteger) numberOfPendingConferenceRoomInvitations;

/**
 *  Update a room topic
 *
 *  @param room  the room that must be updated
 *  @param topic new topic, can be `nil`
 */
-(void) updateRoom:(Room *) room withTopic:(NSString *) topic;

/**
 *  Update a room name
 *
 *  @param room  the room that must be updated
 *  @param name new name, must be at least 4 chars long
 */
-(void) updateRoom:(Room *) room withName:(NSString *) name;

/**
 *  Upload a room avatar
 *
 *  @param room  the room that must be updated
 *  @param photoData the new photo datas to upload
 */
-(void) updateAvatar:(Room *) room withPhotoData:(NSData *) photoData withCompletionBlock:(void (^)(NSError *error))completionBlock;

/**
 *  Remove a already added participant from the given room
 *  Change the participant state to unsubscribe
 *
 *  @param participant  the participant to remove
 *  @param room         the room where the participant must be removed
 */
-(void) removeParticipant:(Participant *) participant fromRoom:(Room *) room;

/**
 *  Really delete the participant from the given room
 *
 *  Synchronous method ! Must not be invoked on MainThread
 *
 *  @param participant  the participant to delete
 *  @param room         the room where the participant is
 */
-(void) deleteParticipant:(Participant *) participant fromRoom:(Room *) room;

/**
 *  Get participants in the given room, this is a paginated call allowing to retrieve
 *  a range of the participants
 *
 *  @param inRange      the range to retrieve
 *  @param room         the room where the participants are
 */
-(void) getParticipantRange:(NSRange)inRange inRoom:(Room *)room completionBlock:(RoomsServiceUsersCompletionHandler) completionHandler;

/**
 *  Archive a room
 *  If owner archive a room, all participant status will be changed to unsubscribe
 *  If participant archive a room, this participant status will be changed
 *  @param room the room to archive
 */
-(void) archiveRoom:(Room *) room;

/**
 *  Leave the room, this will unsubscribe from the room events (messages, ...)
 *
 *  @param room the room to mute
 */
-(void) leaveRoom:(Room *) room;

/**
 *  Delete a room from server
 *
 *  @param room room to delete
 */
-(void) deleteRoom:(Room *) room;

/**
 *  Delete a room avatar from server
 *
 *  @param room room avatar to delete
 */
-(void) deleteAvatar:(Room *) room;

/**
 *  Search in room name for the given pattern.
 *  This method perform the search action synchronously, so be sure to not invoke it in main thread
 *  @param pattern  pattern to search
 *  @return list of room that match the given pattern
 */
-(NSArray<Room *> *) searchRoomWithPattern:(NSString *) pattern;

/**
 *  Search in room name created by me that begin with the given sub string.
 *  This method perform the search action synchronously, so be sure to not invoke it in main thread
 *  @param str  pattern to search
 *  @return list of room that match the given pattern
 */
-(NSArray<Room *> *) searchMyRoomBeginWith:(NSString *) str;

/**
 *  Attach a conference endpoint to the given room
 *  @param confEndpoint         ConfEndpoint to attach
 *  @param room                 room where to attach the conference
 *  @param completionHandler    block executed at the completion
 */
-(void) attachConferenceEndpoint:(ConfEndpoint *) confEndpoint inRoom:(Room *) room completionBlock:(RoomsServiceAttachConferenceCompletionHandler) completionHandler;

/**
 *  Detach a conference from this room
 *  @param conference       conference to dettach sharing
 *  @param room             room where to share the conference
 *  @param completionHandler    block executed at the completion
 */
-(void) detachConference:(Conference *) conference fromRoom:(Room *) room completionBlock:(RoomsServiceDetachConferenceCompletionHandler) completionHandler;

/**
 *  Get detail of a room
 *  @param room                 room we want get detail from
 *  A didUpdateRoom notification will be triggered when all the details will be received
 */
-(void) fetchRoomDetails:(Room *) room;

/**  Search in room name created by me that match exctally the given string.
 *  This method perform the search action synchronously, so be sure to not invoke it in main thread
 *  @param str  pattern to search
 *  @return list of room that match the given pattern
 */
-(NSArray<Room *> *) searchMyRoomMatchName:(NSString *) str;

/**
 *  Update room with custom data
 *  @param room The room we want to manage associated custom data
 *  @param datas A key/value list of data
 */
-(void) updateRoom:(Room *) room withCustomData:(NSDictionary*)datas completionBlock:(RoomsServiceManageCustomDataCompletionHandler) completionHandler;

@end
