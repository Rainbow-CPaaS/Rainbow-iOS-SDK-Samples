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
#import "Contact.h"

/**
 *  Group representation
 */
@interface Group : NSObject

/**
 *  Group name
 */
@property (nonatomic, readonly) NSString *name;

/**
 *  Optional comment
 */
@property (nonatomic, readonly) NSString *comment;

/**
 *  Group owner
 */
@property (nonatomic, readonly) Contact *owner;

/**
 *  Group creation date
 */
@property (nonatomic, readonly) NSDate *creationDate;

/**
 *  List of users in the group
 */
@property (nonatomic, readonly) NSArray<Contact *> *users;

@end
