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
#import "Server.h"
#import "Contact.h"

// User notification sent when features has been updated
FOUNDATION_EXPORT NSString *const kMyUserFeatureDidUpdate;
// Notification sent when there is an update of profiles for the logged user
FOUNDATION_EXPORT NSString *const kMyUserProfilesDidUpdate;

/**
 *  All informations about the currenlty logged user
 */
@interface MyUser : NSObject
/** @name MyUser properties */
/** username of the logged user */
@property (nonatomic, readonly) NSString *username;
/** password of the logged user */
@property (nonatomic, readonly) NSString *password;
/** Server where the logged user is connected 
 *  @see Server
 */
@property (nonatomic, readonly) Server *server;
/** Contact object that represent the logged user
 * @see Contact
 */
@property (nonatomic, readonly) Contact *contact;
/** Boolean value to known if the user is correclyt initialized on server side */
@property (nonatomic, readonly) BOOL isInitialized;

// Boolean value to known if the user is in the default company
@property (nonatomic, readonly) BOOL isInDefaultCompany;

// Roles attributed to the user
@property (nonatomic, readonly) NSArray *roles;

// Check if the connected user is a "simple" user, not an admin or a superadmin
@property (nonatomic, readonly) BOOL isUser;

// Check if the connected user is a guest
@property (nonatomic, readonly) BOOL isGuest;

// Check if the user is allowed to use webRTC on mobile
@property (nonatomic, readonly) BOOL isAllowedToUseWebRTCMobile;

// Check if the user is allowed to participate in webRTC call
@property (nonatomic, readonly) BOOL isAllowedToParticipateInWebRTCConference;

// Check if the user is allowed to use telephony conference
@property (nonatomic, readonly) BOOL isAllowedToUseTelephonyConference;

// Check if the user is allowed to use the webRTC Telephony conference
@property (nonatomic, readonly) BOOL isAllowedToUseWebRTCTelephonyConference;

// Check if the user is allowed to participate in telephony conference
@property (nonatomic, readonly) BOOL isAllowedToParticipateInTelephonyConference;

// Check if the user is allowed to use webRTC Video on mobile
@property (nonatomic, readonly) BOOL isAllowedToUseWebRTCMobileVideo;

// Check if the user is allow to user active directory search
@property (nonatomic, readonly) BOOL isAllowedToSearchInActiveDirectory;

@property (nonatomic, readonly) BOOL isAllowedToParticipateInWebRTCMobile;

// Maximum number of participant in room
@property (nonatomic, readonly) NSInteger maxNumberOfParticipantPerRoom;

// Maximum number of WebRTC participants in room
@property (nonatomic, readonly) NSInteger maxNumberOfWebRTCParticipantsPerRoom;

// Name of profile associated to user
@property (nonatomic, readonly) NSArray *profilesName;

// Check if the user can create conference. Change when PGI server is ready.
@property (nonatomic, readonly) BOOL isReadyToCreateConference;

// The Application ID string
@property (nonatomic, readonly) NSString *appID;

// The secret key associated to the AppID
@property (nonatomic,readonly) NSString *secretKey;

// The application token received from server
@property (nonatomic,readonly) NSString *appToken;

@end
