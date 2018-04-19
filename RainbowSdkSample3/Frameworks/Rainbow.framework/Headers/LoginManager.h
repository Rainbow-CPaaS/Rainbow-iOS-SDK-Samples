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

/** @name Login manager Notifications */
/** Notification sent before starting login */
FOUNDATION_EXPORT NSString *const kLoginManagerWillLogin;
/** Login manager did login succeeded notification */
FOUNDATION_EXPORT NSString *const kLoginManagerDidLoginSucceeded;
// Login manager did logout succeeded notification
FOUNDATION_EXPORT NSString *const kLoginManagerDidLogoutSucceeded;
// Login manager did lost connection notification
FOUNDATION_EXPORT NSString *const kLoginManagerDidLostConnection;
// Login manager did lost connection notification
FOUNDATION_EXPORT NSString *const kLoginManagerDidReconnect;
// Login manager did failed to authenticate notification
FOUNDATION_EXPORT NSString *const kLoginManagerDidFailedToAuthenticate;
// Login manager server url change notification
FOUNDATION_EXPORT NSString *const kLoginManagerDidChangeServer;
// Login manager notification sent when user is changed
FOUNDATION_EXPORT NSString *const kLoginManagerDidChangeUser;
// Login manager notification sent when a connection seams too long
FOUNDATION_EXPORT NSString *const kLoginManagerTryToReconnect;

/**
 *  Completion handler for registration process
 *
 *  @param jsonResponse the server json answer in dictionary format
 *  @param error        the returned error in case of error
 */
typedef void(^LoginManagerRegistrationCompletionHandler)(NSDictionary *jsonResponse, NSError *error);

/**
 *
 *  Manage connection and disconnection to the server
 *  It is also in charge of user account creation, or reset user password
 */
@interface LoginManager : NSObject
/** @name LoginManager properties */

/**
 *  Connection status, `YES` when connection with server is enabled
 */
@property (nonatomic, readonly) BOOL isConnected;

/**
 *  This boolean will return the `YES` if the login success at least one time
 */
@property (nonatomic, readonly) BOOL loginDidSucceed;

/**
 *  This boolean is by default to `YES`, when the user disconnect manually this boolean will be set to `NO`
 */
@property (nonatomic, readonly) BOOL autoLogin;

/**
 *  Return a float value of the server api version, eg: 15.0
 */
@property (nonatomic, readonly) NSNumber *serverApiVersion;

/** @name Login manager connection methods */

/**
 *  Defines username and password of the user to logged in
 *
 *  @param username the username of the user
 *  @param password the password of the user
 *  @discussion username and password given to this method are automatically saved in the device keychain.
 */
-(void) setUsername:(NSString *) username andPassword:(NSString *) password;


/**
 *  Methods use to clean all saved credentials login/password in keychain etc...
 */
-(void) resetAllCredentials;

/**
 *  Connection method
 *  @discussion this method is asynchronous, monitor LoginManager notifications for success or failure.
 *
 *  Notifications sent :
 *
 *  - `kLoginManagerDidLoginSucceeded`
 *
 *  - `kLoginManagerDidFailedToAuthenticate`
 */
-(void) connect;

/**
 *  Invoke logout method and disconnect xmpp service
 *  @discussion this method is asynchronous, monitor LoginManager notifications for success or failure.
 *
 *  Notifications sent :
 *
 *  - `kLoginManagerDidLogoutSucceeded`
 */
-(void) disconnect;

/** @name User self registration or password reset */

/**
 *  This API allows to send a self-register email to a user. A temporary user token is generated and send in the email body. This token is required in the self register validation workflow
 *
 *  @param emailAddress      Email of the user requesting a self-register email with a temporary token
 *  @param completionHandler called when we got a server answer.
 */
-(void) sendNotificationForEnrollmentTo:(NSString *) emailAddress completionHandler:(LoginManagerRegistrationCompletionHandler) completionHandler;

/**
 *  This api allows a user to self register in Rainbow application.
 *
 *  @param loginEmail        User email address (used for login).
 *  @param password          User password.
 *  @param temporaryCode     User temporary token.
 *  @param completionHandler called when we got a server answer.
 */
-(void) sendSelfRegisterRequestWithLoginEmail:(NSString *) loginEmail password:(NSString *) password temporaryCode:(NSString *) temporaryCode completionHandler:(LoginManagerRegistrationCompletionHandler) completionHandler;

/**
 * This api allow a user to complete the registration process in Rainbow application after receiving an invitation email with an invitationID.
 *  @param loginEmail        User email address (used for login).
 *  @param password          User password.
 *  @param invitationID      Invitation ID received by email
 *  @param completionHandler called when we got a server answer.
 */
-(void) sendSelfRegisterRequestWithLoginEmail:(NSString *) loginEmail password:(NSString *) password invitationId:(NSString *) invitationId completionHandler:(LoginManagerRegistrationCompletionHandler) completionHandler;

-(void) sendSelfRegisterRequestWithLoginEmail:(NSString *) loginEmail password:(NSString *) password invitationId:(NSString *) invitationId visibility:(NSString *) visibility completionHandler:(LoginManagerRegistrationCompletionHandler) completionHandler;

/**
 * This api allow a user to complete the registration process in Rainbow application after receiving an invitation email with an invitationID.
 *  @param loginEmail        User email address (used for login).
 *  @param password          User password.
 *  @param joinCompanyInvitationId      Invitation ID received by email for joining a specific company
 *  @param completionHandler called when we got a server answer.
 */
-(void) sendSelfRegisterRequestWithLoginEmail:(NSString *) loginEmail password:(NSString *) password joinCompanyInvitationId:(NSString *) joinCompanyInvitationId completionHandler:(LoginManagerRegistrationCompletionHandler) completionHandler;

/**
 *  This api allows a user to reset his Rainbow password.
 *  He will receive an email with an activation code.
 *
 *  @param loginEmail        User email address
 *  @param completionHandler called when we got a server answer.
 */
-(void) sendResetPasswordEmailWithLoginEmail:(NSString *) loginEmail completionHandler:(LoginManagerRegistrationCompletionHandler) completionHandler;

/**
 *  This api allows a user to reset his Rainbow password.
 *
 *  @param loginEmail        User email address
 *  @param password          new user password
 *  @param temporaryCode     User temporary token received by email
 *  @param completionHandler called when we got a server answer.
 */
-(void) sendResetPasswordWithLoginEmail:(NSString *) loginEmail password:(NSString *) password temporaryCode:(NSString *) temporaryCode completionHandler:(LoginManagerRegistrationCompletionHandler) completionHandler;

/**
 *  This api allows a user to change his Rainbow password.
 *
 *  @param oldPassword        Previous user password.
 *  @param password           New user password
 *  @param completionHandler called when we got a server answer.
 */
-(void) sendChangePassword:(NSString *) oldPassword newPassword:(NSString *) password completionHandler:(LoginManagerRegistrationCompletionHandler) completionHandler;

@end
