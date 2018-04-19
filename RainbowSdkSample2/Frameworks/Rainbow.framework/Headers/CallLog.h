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
#import "Contact.h"
#import "Peer.h"

typedef NS_ENUM(NSInteger, CallLogState) {
    CallLogStateMissed,
    CallLogStateAnswered,
    CallLogStateUnknown
};

typedef NS_ENUM(NSInteger, CallLogMedia) {
    CallLogMediaAudio,
    CallLogMediaVideo,
    CallLogMediaUnknown
};

typedef NS_ENUM(NSInteger, CallLogType){
    CallLogTypeWebRTC,
    CallLogTypePhone,
    CallLogTypeUnknown
};

typedef NS_ENUM(NSInteger, CallLogService){
    CallLogServiceConference,
    CallLogServiceUnknown
};

@interface CallLog : NSObject

// Peer of the callLog
@property (nonatomic, readonly) Peer *peer;
// Type of callLog
@property (nonatomic, readonly) CallLogType type;
// Service of callLog
@property (nonatomic, readonly) CallLogService service;
// State if the callLog
@property (nonatomic, readonly) CallLogState state;
// Date of the callLog
@property (nonatomic, readonly) NSDate *date;
// Duration of the call in second, nil for Missed callLog
@property (nonatomic, readonly) NSString *duration;
// Media used during this callLog, CallLogMediaUnknown for Missed callLog
@property (nonatomic, readonly) CallLogMedia media;
// flag for outgoing callLog
@property (nonatomic, readonly) BOOL isOutgoing;

@end
