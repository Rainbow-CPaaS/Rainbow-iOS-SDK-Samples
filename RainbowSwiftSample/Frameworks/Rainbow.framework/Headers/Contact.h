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
#import "Presence.h"
#import "CalendarPresence.h"
#import "PhoneNumber.h"
#import "EmailAddress.h"
#import "PostalAddress.h"
#import "Peer.h"
#import "Invitation.h"
#import "CompanyInvitation.h"

// Define all the keys supported for KVO
// As I don't like KVO, there is just a small list
#define kContactFirstNameKey @"firstName"
#define kContactLastNameKey @"lastName"
#define kContactLastActivityDateKey @"lastActivityDate"
// kContactPresenceKey is also allowed.

/**
 *  Defines a Contact object which inherit from Peer.
 */
@interface Contact : Peer


// -- All the properties from GenericContact

/**
 *  The user's Avatar
 */
@property (nonatomic, readonly) NSData *photoData;

/**
 *  The user's first name
 */
@property (nonatomic, readonly) NSString *firstName;

/**
 *  The user's last name
 */
@property (nonatomic, readonly) NSString *lastName;

/**
 *  The user's nick name
 */
@property (nonatomic, readonly) NSString *nickName;

/**
 *  The user's phone numbers
 */
@property (nonatomic, readonly) NSArray<PhoneNumber*> *phoneNumbers;

/**
 *  The user's email addresses
 */
@property (nonatomic, readonly) NSArray<EmailAddress*> *emailAddresses;

/**
 *  The user's title (honorifics title, like Mr, Mrs, Sir, Lord, Lady, Dr, Prof,...)
 */
@property (nonatomic, readonly) NSString *title;

/**
 *  The user's job title
 */
@property (nonatomic, readonly) NSString *jobTitle;

/**
 *  The user's time zone
 */
@property (nonatomic, readonly) NSTimeZone *timeZone;

/**
 *  The user's company rainbowID
 */
@property (nonatomic, readonly) NSString *companyId;

/**
 *  The user's company name
 */
@property (nonatomic, readonly) NSString *companyName;



// -- All the properties from LocalContact

/**
 *  The user's postal addresses
 */
@property (nonatomic, readonly) NSArray<PostalAddress*> *addresses;

/**
 *  The user's websites
 */
@property (nonatomic, readonly) NSArray<NSString *> *webSitesURL;


// -- All the properties from RainbowContact

/**
 *  Whether the information of the user has been retrieved from the server
 */
@property (nonatomic, readonly) BOOL vcardPopulated;

/**
 *  The user's JID
 */
@property (nonatomic, readonly) NSString *jid;

/**
 *  The user's telephone JID
 */
@property (nonatomic, readonly) NSString *jid_tel;

/**
 *  The user's Rainbow ID
 */
@property (nonatomic, readonly) NSString *rainbowID;

/**
 *  Whether the user is in our roster
 */
@property (nonatomic, readonly) BOOL isInRoster;

/**
 *  Whether we have subscribed to the user's presence
 */
@property (nonatomic, readonly) BOOL isPresenceSubscribed;

/**
 *  New invitation system. When this user send us an invitation
 *  through REST api (or old xmpp roster) it is linked here.
 */
@property (nonatomic, readonly) Invitation *requestedInvitation;

/**
 *  New invitation system. When we sent an invitation to this user
 *  through REST api (or old xmpp roster) it is linked here.
 */
@property (nonatomic, readonly) Invitation *sentInvitation;

@property (nonatomic, readonly) CompanyInvitation *companyInvitation;

/**
 *  The user's XMPP groups
 */
@property (nonatomic, readonly) NSArray<NSString*> *groups;

/**
 *  The user's current presence
 */
@property (nonatomic, readonly) Presence *presence;

/**
 *  The user's current presence
 */
@property (nonatomic, readonly) CalendarPresence *calendarPresence;

/**
 *  Whether the user is connected with at least one mobile or not
 */
@property (nonatomic, readonly) BOOL isConnectedWithMobile;

/**
 *  Time of the last user profile update
 */
@property (nonatomic, readonly) NSDate *lastUpdateDate;

/**
 *  Whether the user is a bot (like Emily) or not
 */
@property (nonatomic, readonly) BOOL isBot;

/**
 *  The last time this user has been active (its a server information)
 */
@property (nonatomic, readonly) NSDate *lastActivityDate;


// -- Other easy-to-use properties, which are computed from previous values

/**
 *  The user full name, which is a concatenation of the first and last names
 */
@property (nonatomic, readonly) NSString *fullName;

/**
 *  Whether the user is a rainbow user or not
 */
@property (nonatomic, readonly) BOOL isRainbowUser;

/**
 *  Whether the user is a temporary invited rainbow user or not
 */
@property (nonatomic, readonly) BOOL isInvitedUser;

/**
 *  Whether we can chat with the user or not
 */
@property (nonatomic, readonly) BOOL canChatWith;

/**
 *  Whether the user is "visible" or not
 */
@property (nonatomic, readonly) BOOL isVisible;

/**
 *  Whether the user is muted or not
 */
@property (nonatomic, readonly) BOOL isMuted;

/**
 *  The user's country code following ISO 3166-1 alpha3 format
 */
@property (nonatomic, readonly) NSString *countryCode;

/**
 *  The user's language in ISO 639-1 format
 */
@property (nonatomic, readonly) NSString *language;

// return YES if the contact came from an external server (for exemple Active directory)
@property (nonatomic, readonly) BOOL isExternalContact;


// -- Function helpers

-(PhoneNumber *) getPhoneNumberOfType:(PhoneNumberType) type;
-(BOOL) hasPhoneNumberOfType:(PhoneNumberType) type;
-(PhoneNumber *) getPhoneNumberOfType:(PhoneNumberType) type withDeviceType:(PhoneNumberDeviceType) deviceType;
-(BOOL) hasPhoneNumberOfType:(PhoneNumberType) type withDeviceType:(PhoneNumberDeviceType) deviceType;
-(EmailAddress *) getEmailAdressOfType:(EmailAddressType) type;
-(BOOL) hasEmailAddressOfType:(EmailAddressType) type;

-(NSString *) jsonRepresentation;
-(NSDictionary *) dictionaryRepresentation;
// Return the full representation of a contact with all fields
-(NSDictionary *) dictionaryRepresentation:(BOOL) fullRepresensation;

@end
