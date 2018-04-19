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
#import "CallLog.h"
#import "Contact.h"

FOUNDATION_EXPORT NSString *const kCallLogsServiceDidFetchCallLogs;
FOUNDATION_EXPORT NSString *const kCallLogsServiceDidAddCallLog;
FOUNDATION_EXPORT NSString *const kCallLogsServiceDidUpdateCallLog;
FOUNDATION_EXPORT NSString *const kCallLogsServiceDidRemoveCallLog;
FOUNDATION_EXPORT NSString *const kCallLogsServiceDidRemoveAllCallLogs;
FOUNDATION_EXPORT NSString *const kCallLogsServiceDidRemoveCallLogs;
FOUNDATION_EXPORT NSString *const kCallLogsServiceDidUpdateCallLogsUnreadCount;
@interface CallLogsService : NSObject
// List of all callLogs
@property (nonatomic, readonly) NSArray <CallLog*> * callLogs;
/** Total number of unread callLogs */
@property (nonatomic, readonly) NSInteger totalNbOfUnreadCallLogs;

-(void) deleteCallLogWithPeer:(Peer *) peer;
-(void) deleteAllCallLogs;
-(void) markAllCallLogsAsRead;
@end
