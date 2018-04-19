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

//! Project version number for SDK.
FOUNDATION_EXPORT double RainbowVersionNumber;

//! Project version string for SDK.
FOUNDATION_EXPORT const unsigned char RainbowVersionString[];

// Service import
#import <Rainbow/ServicesManager.h>
#import <Rainbow/LoginManager.h>
#import <Rainbow/MessagesBrowser.h>
#import <Rainbow/CKBrowsingOperation.h>
#import <Rainbow/CKItemsBrowser+protected.h>
#import <Rainbow/Message+Browsing.h>
#import <Rainbow/MessagesBrowser.h>
#import <Rainbow/CKItemsBrowser.h>
#import <Rainbow/CKBrowsableItem.h>
#import <Rainbow/ContactsManagerService.h>
#import <Rainbow/ConversationsManagerService.h>
#import <Rainbow/RoomsService.h>
#import <Rainbow/GroupsService.h>
#import <Rainbow/NotificationsManager.h>
#import <Rainbow/CompaniesService.h>
#import <Rainbow/FileSharingService.h>
#import <Rainbow/RainbowUserDefaults.h>
#import <Rainbow/ConferencesManagerService.h>
#import <Rainbow/CallLogsService.h>
#import <Rainbow/MessagesAlwaysInSyncBrowserAddOn.h>

#import <Rainbow/LogsRecorder.h>
#import <Rainbow/defines.h>
#import <Rainbow/Tools.h>
#import <Rainbow/NSDate+Utilities.h>
#import <Rainbow/UIDevice+VersionCheck.h>
#import <Rainbow/UIImage+Thumbnail.h>
#import <Rainbow/NSString+FileSize.h>
#import <Rainbow/NSData+MimeType.h>
#import <Rainbow/NSDictionary+ChangedKeys.h>
#import <Rainbow/NSDate+Distance.h>
#import <Rainbow/OrderedDictionary.h>
#import <Rainbow/ChannelsService.h>

// RTC Service
#import <Rainbow/RTCService.h>

// Datamodel import
#import <Rainbow/MyUser.h>
#import <Rainbow/Peer.h>
#import <Rainbow/Room.h>
#import <Rainbow/Contact.h>
#import <Rainbow/EmailAddress.h>
#import <Rainbow/PhoneNumber.h>
#import <Rainbow/PostalAddress.h>
#import <Rainbow/Presence.h>
#import <Rainbow/CalendarPresence.h>
#import <Rainbow/Message.h>
#import <Rainbow/Server.h>
#import <Rainbow/Conversation.h>
#import <Rainbow/Room.h>
#import <Rainbow/Participant.h>
#import <Rainbow/Group.h>
#import <Rainbow/Invitation.h>
#import <Rainbow/Company.h>
#import <Rainbow/CompanyInvitation.h>
#import <Rainbow/RTCCall.h>
#import <Rainbow/File.h>
#import <Rainbow/CallLog.h>
#import <Rainbow/Conference.h>
#import <Rainbow/ConferenceParticipant.h>
#import <Rainbow/ConfEndpoint.h>
#import <Rainbow/Channel.h>
#import <Rainbow/ChannelPayload.h>
#import <Rainbow/ChannelUser.h>
