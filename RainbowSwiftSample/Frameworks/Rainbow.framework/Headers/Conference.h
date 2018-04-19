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
#import "ConfEndpoint.h"
#import "ConferenceParticipant.h"
#import "ConferencePublisher.h"

/**
 *  The different conference type
 */
typedef NS_ENUM(NSInteger, ConferenceType) {
    ConferenceTypeUnknown = 0,
    /**
     *  Instant conference type
     */
    ConferenceTypeInstant,
    /**
     *  Scheduled conference type
     */
    ConferenceTypeScheduled
};

@interface Conference : NSObject
@property (nonatomic, readonly) ConferenceType type;
@property (nonatomic, readonly) NSString *confId;
@property (nonatomic, readonly) Contact *owner;
@property (nonatomic, readonly) BOOL isMyConference;
@property (nonatomic, readonly) NSDate *start;
@property (nonatomic, readonly) NSDate *end;
@property (nonatomic, readonly) NSArray<ConferenceParticipant*> *participants;
@property (nonatomic, readonly) NSArray<ConferencePublisher*> *publishers;
@property (nonatomic, readonly) ConfEndpoint *endpoint;
// Facilitor to get my own participant object
@property (nonatomic, readonly) ConferenceParticipant *myConferenceParticipant;

@property (nonatomic, readonly) BOOL canJoin;
@property (nonatomic, readonly) BOOL isActive;
@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, readonly) BOOL isTalkerActive;
@property (nonatomic, readonly) BOOL allParticipantsMuted;

@property (nonatomic, readonly) BOOL endedConference;
@end
