/*
 * Rainbow
 *
 * Copyright (c) 2019, ALE International
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
#import "File.h"

@interface VoiceMessage : NSObject

// Identifiant of the voice message
@property (nonatomic, readonly) NSString *voiceMessageId;
// File of the voice message
@property (nonatomic, readonly) File *attachment;
// Contact of the voice message
@property (nonatomic, readonly) Contact *contact;
// Date of the voice message
@property (nonatomic, readonly) NSDate *date;
// Duration of the voice message in second
@property (nonatomic, readonly) int duration;
// flag for callable
@property (nonatomic, readonly) BOOL isCallable;
// Flag for unread
@property (nonatomic, readonly) BOOL isRead;

@end
