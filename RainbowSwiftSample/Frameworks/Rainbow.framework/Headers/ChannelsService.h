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
#import "Channel.h"
#import "ChannelPayload.h"
#import "ChannelUser.h"

FOUNDATION_EXPORT NSString *const kChannelsServiceDidReceiveItem;
FOUNDATION_EXPORT NSString *const kChannelsServiceDidRetractItem;

@interface ChannelDescription : NSObject
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *topic;
@property (nonatomic, readonly) NSString *id;
@property (nonatomic, readonly) ChannelUserType userType;
@property (nonatomic, readonly) NSString *creatorId;
@end

#define MAX_ITEMS_IN_CHANNEL 100
/**
 * Manager channels
 */
@interface ChannelsService : NSObject

typedef void (^ChannelsServiceCompletionHandler) (NSError *error);
typedef void (^ChannelsServiceGetMyChannelsCompletionHandler) (NSArray<ChannelDescription *> *channelDescriptions, NSError *error);
typedef void (^ChannelsServiceFindChannelsCompletionHandler) (NSArray<ChannelDescription *> *channelDescriptions, NSError *error);
typedef void (^ChannelsServiceGetChannelCompletionHandler) (Channel *channel, NSError *error);
typedef void (^ChannelsServiceGetItemsCompletionHandler) (NSInteger availableItemsCount, NSArray<ChannelPayload *> *items, NSError *error);
typedef void (^ChannelsServiceGetUsersCompletionHandler) (NSArray<ChannelUser *> *users, NSError *error);

/**
 * Dictionary with all published items in channels the user is involved.
 * The dictionnary key is the channel id.
 * At login time this dictionary is filled automatically and updated with
 * subscribed channel update notifications.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, Channel *> *channels;

/**
 *  Create a channel
 *  @param  name                the channel name
 *  @param  topic               the optional channel topic, pass nil if not used
 *  @param  maxItems            the optional max items to persist, pass -1 for default
 *  @param  visibility          the optional max payload size, pass -1 for default
 *  @param  completionHandler   completion handler
 */
-(void) createChannelWithName:(NSString *)name topic:(NSString *)topic visibility:(ChannelVisibility)visibility maxItems:(int)maxItems maxPayloadSize:(int)maxPayloadSize completionHandler:(ChannelsServiceGetChannelCompletionHandler) completionHandler;

/**
 *  Delete a channel
 *  @param  completionHandler   completion handler
 */
-(void) deleteChannelWithId:(NSString *)id completionHandler: (ChannelsServiceCompletionHandler) completionHandler;

/**
 *  Get a channel by its id
 *  @param  id                  the channel id
 *  @param  completionHandler   completion handler
 */
-(void)getChannelById:(NSString *)id completionHandler: (ChannelsServiceGetChannelCompletionHandler) completionHandler;

/**
 *  Enumerate all my channels by kinds, the ones I'm member of, the ones I'm also publisher and the ones I'm the owner
 *  @param  completionHandler   completion handler
 */
-(void)getMyChannelsWithCompletionHandler: (ChannelsServiceGetMyChannelsCompletionHandler) completionHandler;

/**
 *  Publish a message to a channel
 *  @param  title               the message title
 *  @param  message             the message text
 *  @param  url                 a optional link url
 *  @param  completionHandler   completion handler
 */
-(void)publishMessageToChannel:(Channel *)channel title:(NSString *)title message:(NSString *)message url:(NSString *)url completionHandler:(ChannelsServiceCompletionHandler) completionHandler;

/**
 *  Subscribe to a channel
 *  @param  channel             the channel to subscribe
 *  @param  completionHandler   completion handler
 */
-(void)subscribeToChannel:(Channel *)channel completionHandler:(ChannelsServiceCompletionHandler) completionHandler;

/**
 *  Unsubscribe to a channel
 *  @param  channel             the channel to unsubscribe
 *  @param  completionHandler   completion handler
 */
-(void)unsubscribeToChannel:(Channel *)channel completionHandler:(ChannelsServiceCompletionHandler) completionHandler;

/**
 *  Get the n last items from a channel
 *  @param  count               max items to get, 0 to only query the available items
 *  @param  channel             the channel
 *  @param  completionHandler   completion handler
 */
-(void)get:(NSInteger)count itemsFromChannel:(Channel *)channel completionHandler:(ChannelsServiceGetItemsCompletionHandler) completionHandler;

/**
 *  Get the first page of the channel users list
 *  @param  channel             the channel
 *  @param  completionHandler   completion handler
 */
-(void)getFirstUsersFromChannel:(Channel *)channel completionHandler:(ChannelsServiceGetUsersCompletionHandler) completionHandler;

/**
 *  Get a page of the channel users list starting at a given index
 *  @param  channel             the channel
 *  @param  index               start index in the channel user list
 *  @param  completionHandler   completion handler
 */
-(void)getNextUsersFromChannel:(Channel *)channel atIndex:(NSInteger)index completionHandler:(ChannelsServiceGetUsersCompletionHandler) completionHandler;

/**
 *  Find channels whose name match a given substring
 *  @param  name                the part of channels name to search
 *  @param  limit               allow to specify a limit to the number of channels to retrieve, pass -1 for the default (100)
 *  @param  completionHandler   completion handler
 */
-(void)findChannelByName:(NSString *)name limit:(NSInteger)limit completionHandler:(ChannelsServiceFindChannelsCompletionHandler) completionHandler;

/**
 *  Find channels whose topic match a given substring
 *  @param  topic               the part of channels topic to search
 *  @param  limit               allow to specify a limit to the number of channels to retrieve, pass -1 for the default (100)
 *  @param  completionHandler   completion handler
 */
-(void)findChannelByTopic:(NSString *)topic limit:(NSInteger)limit completionHandler:(ChannelsServiceFindChannelsCompletionHandler) completionHandler;

/**
 *  Update channel's topic
 *  @param  id                  the channel Id
 *  @param  topic               the new topic
 *  @param  completionHandler   completion handler
 */
-(void)updateChannelWithId:(NSString *)id topic:(NSString *)topic completionHandler:(ChannelsServiceCompletionHandler) completionHandler;

/**
 *  Update channel's visibility
 *  @param  id                  the channel Id
 *  @param  visibility          the new visibility
 *  @param  completionHandler   completion handler
 */
-(void)updateChannelWithId:(NSString *)id visibility:(ChannelVisibility)visibility completionHandler:(ChannelsServiceCompletionHandler) completionHandler;

/**
 *  Update channel's max items
 *  @param  id                  the channel Id
 *  @param  maxItems            the new max of items
 *  @param  completionHandler   completion handler
 */
-(void)updateChannelWithId:(NSString *)id maxItems:(NSUInteger)maxItems completionHandler:(ChannelsServiceCompletionHandler) completionHandler;

/**
 *  Update channel's max payload size
 *  @param  id                  the channel Id
 *  @param  maxPayloadSize      the new max payload size
 *  @param  completionHandler   completion handler
 */
-(void)updateChannelWithId:(NSString *)id maxPayloadSize:(NSUInteger)maxPayloadSize completionHandler:(ChannelsServiceCompletionHandler) completionHandler;

@end
