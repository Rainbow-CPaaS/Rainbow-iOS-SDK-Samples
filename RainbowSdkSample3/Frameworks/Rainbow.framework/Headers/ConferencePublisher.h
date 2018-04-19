/*
 * Rainbow
 *
 * Copyright (c) 2018, ALE International
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

typedef NS_ENUM(NSInteger, PublisherMediaType){
    PublisherMediaTypeSharing = 0,
    PublisherMediaTypeVideo,
    PublisherMediaTypeUnknown
};

@interface ConferencePublisher : NSObject
@property (nonatomic, readonly) Contact *contact;
@property (nonatomic, readonly) NSString *publisherID;
@property (nonatomic, readonly) PublisherMediaType mediaType;
@property (nonatomic, readonly) NSString *jidIM;
@property (nonatomic, readonly) BOOL subscribed;
@end
