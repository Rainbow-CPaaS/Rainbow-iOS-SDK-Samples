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
#import "LoginManager.h"
#import "ContactsManagerService.h"
#import "RTCService.h"
#import "MyUser.h"
#import "ConversationsManagerService.h"
#import "RoomsService.h"
#import "GroupsService.h"
#import "NotificationsManager.h"
#import "CompaniesService.h"
#import "FileSharingService.h"
#import "ConferencesManagerService.h"
#import "CallLogsService.h"
#import "ChannelsService.h"

typedef void (^ServicesManagerDidConnectExtension)(void);
/**
 *  Provide access to all Rainbow services
 */
@interface ServicesManager : NSObject

/**
 *  Rainbow service shared instance
 *
 *  @return services manager sharedInstance
 */
+(ServicesManager*) sharedInstance;

/**
 *  Block code to perform when connection to server is successfull
 *  The block is invoked in a independ thread
 */
@property (nonatomic, copy) ServicesManagerDidConnectExtension actionToPerformHandler;

/**
 *  Login service
 *
 *  Provide access to login manager that allow you to connect to rainbow
 *  @see LoginManager
 */
@property (readonly) LoginManager *loginManager;

/**
 *  Contacts service
 *  @see ContactsManagerService
 */
@property (readonly) ContactsManagerService *contactsManagerService;

/**
 *  WebRTC service
 *  @see RTCService
 */
@property (readonly) RTCService *rtcService;

/**
 *  Rooms service
 *  @see RoomsService
 */
@property (readonly) RoomsService *roomsService;

/**
 *  My User service
 *  @see MyUser
 */
@property (readonly) MyUser *myUser;

/**
 *  Conversations service
 *
 *  @see ConversationsManagerService
 */
@property (readonly) ConversationsManagerService *conversationsManagerService;

/**
 *  Tags Service
 *  Simply add tags to your contacts
 */
@property (readonly) GroupsService *groupsService;

/**
 *  Deal with push notification received from rainbow server
 */
@property (readonly) NotificationsManager *notificationsManager;

@property (readonly) CompaniesService *companiesService;

@property (readonly) FileSharingService *fileSharingService;

/**
 *  Conference service
 *
 *  @see ConferencesManagerService
 */
@property (readonly) ConferencesManagerService *conferencesManagerService;

@property (readonly) CallLogsService *callLogsService;

/**
 * Channels service
 */
@property (readonly) ChannelsService *channelsService;

/**
 * Set the application ID and secret key
 *
 */
-(void)setAppID:(NSString *)appID secretKey:(NSString *)secretKey;

@end
