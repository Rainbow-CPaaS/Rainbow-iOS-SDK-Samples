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
#define kDidUpdateMessagesUnreadCount @"didUpdateMessagesUnreadCount" // Same as kConversationsManagerDidUpdateMessagesUnreadCount

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
    ConversationStatusComposing,
    /**
     *  Paused conversation
     */
    ConversationStatusPaused
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
 * Represent a conversation
 *
 * A conversation is a dialog between the logged-in user and a single Rainbow user, a room (bubble) or a chatbot.
 */
@interface Conversation : NSObject

#pragma mark - Properties

/**
 * @return the conversation unique identifier
 */
@property (nonatomic, readonly) NSString *conversationId;

/**
 * @return the conversation type
 */
@property (readonly) ConversationType type;

/**
 * @return the conversation type string
 * :nodoc:
 */
@property (readonly) NSString *stringForConversationType;

/**
 * @return the recipient Rainbow user or room associated with that conversation
 */
@property (nonatomic, readonly) Peer *peer;

/**
 * @return the number of unread messages in this conversation
 */
@property (nonatomic, readonly) NSInteger unreadMessagesCount;

/**
 * @return the last message received or sent for this conversation
 */
@property (nonatomic, readonly) Message *lastMessage;

/**
 * @return the date of the last update of this conversation (ie: last message sent or received or room creation date)
 */
@property (nonatomic, readonly) NSDate *lastUpdateDate;

/**
 * @return the conversation status
 */
@property (readonly) ConversationStatus status;

/**
 * @return `YES` if the conversation is muted. By default a conversation is not muted
 */
@property (readonly) BOOL isMuted;

/**
 * @return `YES` if the conversation has a ongoing call
 */
@property (nonatomic, readonly) BOOL hasActiveCall;

/**
 *  This property has to be changed on application side to automatically marked as read new messages received
 *      - YES for example in viewWillAppear in the conversation view
 *      - NO for example in viewWillDisappear in the conversation view
 */
@property (nonatomic, readwrite) BOOL automaticallySendMarkAsReadNewMessage;

@end
