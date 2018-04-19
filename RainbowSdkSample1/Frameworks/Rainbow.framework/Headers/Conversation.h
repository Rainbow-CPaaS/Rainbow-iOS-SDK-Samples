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
#import "Peer.h"
#import "Message.h"

#define kConversationLastMessage @"lastMessage"
#define kConversationUnreadMessagesCount @"unreadMessagesCount"
#define kConversationIsMuted @"isMuted"

/**
 *  Conversation status
 */
typedef NS_ENUM(NSInteger, ConversationStatus) {
    /**
     *  Active conversation
     */
    ConversationStatusActive = 0,
    /**
     *  Inactive conversation
     */
    ConversationStatusInactive,
    /**
     *  Composing conversation
     */
    ConversationStatusComposing
};
/**
 *  Conversation type
 */
typedef NS_ENUM(NSInteger, ConversationType) {
    /**
     *  Type unknown
     */
    ConversationTypeUnknown = 0,
    /**
     *  Conversation with a user
     */
    ConversationTypeUser,
    /**
     *  Conversation with a room
     */
    ConversationTypeRoom,
    /**
     *  Conversation with a bot
     */
    ConversationTypeBot
};
/**
 *  Conversation object
 */
@interface Conversation : NSObject
/**
 *  Conversation type
 *  @see ConversationType
 */
@property (readonly) ConversationType type;

/**
 *  Conversation peer
 *  @see Peer
 */
@property (nonatomic, readonly) Peer *peer;

/** Number of unread message in this conversation */
@property (nonatomic, readonly) NSInteger unreadMessagesCount;

/**
 *  Last message received or sent for this conversation
 *  @see Message
 */
@property (nonatomic, readonly) Message *lastMessage;

/**
 *  Date of the last update of this conversation
 *  based on the last message date or the Room creation or the date given by the server
 *
 */
@property (nonatomic, readonly) NSDate *lastUpdateDate;

/**
 *  Conversation status
 *  @see ConversationStatus
 */
@property (readonly) ConversationStatus status;

/**
 *  Return `YES` if the conversation is muted on server side
 *  By default a conversation is not muted
 */
@property (readonly) BOOL isMuted;

@property (nonatomic, readonly) BOOL hasActiveCall;
@end
