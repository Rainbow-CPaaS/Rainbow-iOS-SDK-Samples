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

/**
 This protocol defines selectors any object should implement to be browsable.
 @see CKItemsBrowser
 */
@protocol CKBrowsableItem <NSObject>
/** Returns the date of this browsable item. 
 @return The date of this browsable item. */
-(NSDate*) date;

/** Returns the unique identifier for this browsable item as a `NSNumber` instance.
 @return The unique identifier for this browsable item. */
-(NSString*) referenceIdentifier;
@end