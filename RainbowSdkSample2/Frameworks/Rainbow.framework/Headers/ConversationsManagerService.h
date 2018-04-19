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
#import <UIKit/UIKit.h>
#import "Peer.h"
#import "Contact.h"
#import "Conversation.h"
#import "MessagesBrowser.h"
#import "File.h"

FOUNDATION_EXPORT NSString *const kConversationsManagerDidAddConversation;
FOUNDATION_EXPORT NSString *const kConversationsManagerDidRemoveConversation;
FOUNDATION_EXPORT NSString *const kConversationsManagerDidRemoveAllConversations;
FOUNDATION_EXPORT NSString *const kConversationsManagerDidUpdateConversation;
FOUNDATION_EXPORT NSString *const kConversationsManagerDidStartConversation;
FOUNDATION_EXPORT NSString *const kConversationsManagerDidStopConversation;
FOUNDATION_EXPORT NSString *const kConversationsManagerDidChangeConversation;

FOUNDATION_EXPORT NSString *const kConversationsManagerDidReceiveNewMessageForConversation;
FOUNDATION_EXPORT NSString *const kConversationsManagerDidReceiveComposingMessage;
FOUNDATION_EXPORT NSString *const kConversationsManagerDidAckMessageNotification;
FOUNDATION_EXPORT NSString *const kConversationsManagerDidUpdateMessagesUnreadCount;

FOUNDATION_EXPORT NSString *const kConversationsManagerDidReceiveConferenceReminderInConversation;

/**
 *  Send message completion handler
 *  Method invoked when the send message action is done
 *
 *  @param message Message object sent
 *  @param error   error return by server when the action failed
 */
typedef void (^ConversationsManagerServiceSendMessageCompletionHandler)(Message *message, NSError *error);

typedef void (^ConversationsManagerAttachmentProgressionHandler) (Message* message, double totalBytesSent, double totalBytesExpectedToSend);

typedef void (^ConversationsManagerAttachmentDownloadedComplionHandler) (Message *message, NSError *error);

typedef void (^ConversationsManagerConversationStartedComplionHandler) (Conversation *conversation, NSError *error);
/**
 *  Rainbow conversation service
 */
@interface ConversationsManagerService : NSObject
/** @name ConversationsManager properties */

/** List of all conversations */
@property (nonatomic, readonly) NSArray<Conversation *> *conversations;

/** Total number of unread messages for all conversations */
@property (nonatomic, readonly) NSInteger totalNbOfUnreadMessagesInAllConversations;

/** @name ConversationsManager methods */

/**
 *  Start a new conversation with the given peer
 *
 *  @param peer peer with whom you want to start a conversation
 */
-(void) startConversationWithPeer:(Peer *) peer withCompletionHandler:(ConversationsManagerConversationStartedComplionHandler) completionHandler;

/**
 *  Stop an existing conversation
 *
 *  @param conversation the conversation to stop
 */
-(void) stopConversation:(Conversation *) conversation;

/**
 *  Send message with a attached image action
 *
 *  @param message           message body to send
 *  @param data              data to attach to the message
 *  @param mimeType          data mime type
 *  @param conversation      conversation object in which you want to send the message
 *  @param completionHandler method to invoke when send action is completed
 *  @param progressHandler   method invoked during upload of attachment data to the server (this method is invoked multiple times) 
 *  @return message          return the message.
 */

-(Message *) sendMessage:(NSString *) message fileAttachment:(File *) file to:(Conversation *) conversation completionHandler:(ConversationsManagerServiceSendMessageCompletionHandler) completionHandler attachmentUploadProgressHandler:(ConversationsManagerAttachmentProgressionHandler) progressHandler;

/**
 *  re-send message with a attached image action
 *
 *  @param message           message to re send
 *  @param conversation      conversation object in which you want to send the message
 *  @param completionHandler method to invoke when send action is completed
 *  @param progressHandler   method invoked during upload of attachment data to the server (this method is invoked multiple times)
 *  @return message          return the message.
 */

-(Message *) reSendMessage:(Message *) message to:(Conversation *) conversation completionHandler:(ConversationsManagerServiceSendMessageCompletionHandler) completionHandler attachmentUploadProgressHandler:(ConversationsManagerAttachmentProgressionHandler) progressHandler;

/**
 *  Find a conversation with some one or with a room based on his unique identifier
 *
 *  @param peerJID unique identifier of the conversation
 *
 *  @return The corresponding conversation that match the given unique identifier
 */
-(Conversation *) getConversationWithPeerJID:(NSString *) peerJID;

// XEP-85 - Chat state
/**
 *  Change the status of a conversation
 *
 *  @param status  new conversation status
 *  @param conversation the conversation
 */
-(void) setStatus:(ConversationStatus) status forConversation:(Conversation *) conversation;

// XEP-184 - mark all the messages of a conversation as read (and send the ACK messages)
/**
 *  Mark all messages received for the given conversation as read
 *
 *  @param conversation the conversation to mark as read
 */
-(void) markAsReadByMeAllMessageForConversation:(Conversation *) conversation;

/**
 * Returns a browser to browse messages from the given conversation.
 * @param conversation A conversation from current conversations.
 * @param pageSize The maximum number of retrieved items each time a `nextPage` is invoked on the browser.
 * @param preload retreive imediately from the local cache
 * @return A `MessagesBrowser` instance browsing `Message` items.
 * @see MessagesBrowser
 */
-(MessagesBrowser *) messagesBrowserForConversation:(Conversation *) conversation withPageSize:(NSInteger) pageSize preloadMessages:(BOOL) preload;

/**
 *  Delete all messages for the given conversation
 *
 *  This method is asynchronous, monitor MessagesBrowser delegates `itemsBrowserDidReceivedAllItemsDeletedEvent:` to refresh correclty the UI.
 *  @param conversation the conversation where we want to delete all messages
 *  @see [CKItemsBrowserDelegate itemsBrowserDidReceivedAllItemsDeletedEvent:]
 */
-(void) deleteAllMessagesForConversation:(Conversation *) conversation;

/**
 *  Delete the given message in the given conversation
 *
 *  This method is asynchronous, monitor MessagesBrowser delegates `itemsBrowser:didRemoveCacheItems:atIndexes:` to refresh correclty the UI.
 *
 *  @warning this method is not implemented
 *  @param message      the message to delete
 *  @param conversation the message where the message can be found
 *  @see [CKItemsBrowserDelegate itemsBrowser:didRemoveCacheItems:atIndexes:]
 */
-(void) deleteMessage:(Message *) message inConversation:(Conversation *) conversation;

/**
 *  Mute a conversation
 *  Place a flag on server side to inform that this conversation is muted
 *
 *  @param conversation The conversation that must be muted
 */
-(void) muteConversation:(Conversation *) conversation;

/**
 *  Unmute a conversation
 *  Remove the flag on server side that says a conversation was muted
 *
 *  @param conversation The conversation that must be unmuted.
 */
-(void) unmuteConversation:(Conversation *) conversation;

/**
 *  Extract the conversation content and send it my email to the logged user
 *  This operation is allowed only for peer to peer conversation and room conversations.
 *  All the operations are done on server side.
 *  
 *  This method is synchronous and must not be invoked on mainThread.
 *  @param conversation the conversation to send by email
 *  @return return `YES` if the web service say OK.
 */
-(BOOL) sendConversationByMail:(Conversation *) conversation;

/**
 *  Search in conversation peer for the given pattern.
 *  Search only for conversation of type `ConversationTypeUser`
 *  This method perform the search action synchronously, so be sure to not invoke it in main thread
 *  @param pattern  pattern to search
 *  @return list of conversation of type ConversationTypeUser that match the given pattern
 */
-(NSArray<Conversation *> *) searchConversationWithPattern:(NSString *) pattern;

-(void) downloadAttachmentForMessage:(Message *) message completionHandler:(ConversationsManagerAttachmentDownloadedComplionHandler) completionHandler;

-(void) handleContinueUserActivity:(NSUserActivity *)userActivity error:(NSError **)errorPointer waitingForResponse:(void (^_Nullable)(BOOL receivedResponse))waitingForResponseBlock restorationHandler:(void (^_Nullable)(NSArray * _Nullable))restorationHandler;
@end
