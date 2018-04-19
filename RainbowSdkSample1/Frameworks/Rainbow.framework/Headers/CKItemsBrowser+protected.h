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
#import "CKItemsBrowser.h"
#import "CKBrowsingOperation.h"

@interface CKItemsBrowser (internal)

/**
 Asks for a browsing operation "next page" instance. Subclasses should override this selector
 and provide corresponding concrete implementation.
 */
-(CKBrowsingOperation*) nextPageOperation;

/**
 @return `NSNotFound` constant value if the new item cannot be inserted because was already present in cache.
 */
-(NSInteger) insertItemAtProperIndex:(id<CKBrowsableItem>)aNewItem;

/**
 Updates the browsing cache with items from the given page.
 @param startsAtHead `YES` if the given page represents the browsing cache head. 
 This means, that the first item of this new page must also be the first item of the cache **without any other item before it !**.
 If this param is set to `YES` any item before the first item of this new page will be removed.
 */
-(void) updateBrowsingCacheWithPage:(NSArray*)newPage withCompletionHandler:(CKItemsBrowsingCompletionHandler)hdlr;

/** Removes an array of items from the current browsing cache.
 Notify delegate that those items have been removed.
 @return The items that have been found in the browsing cache and that have been removed. */
-(NSArray*) removeCacheItems:(NSArray*)itemsToBeRemoved;

/**
 This selector is invoked during browsing cache updates and can be overriden to detect changes between
 current cache items and their most recent update.
 @return items that have been updated.
 @see updateBrowsingCacheWithPage:startsAtHead:withCompletionHandler:
 */
-(NSArray*) applyChangesToCurrentCacheItems:(NSArray*)cachedItems fromFreshItems:(NSArray*)updatedItems;

/* 
 Checks if the given items are still at the right index by checking at their date.
 If they are misplaced, change their index and notify delegate.
 @return Items whose indexes have been changed.
 */
-(NSArray*) checkForMisplacedItemsAndReorderIfAny :(NSArray*) items ;

/** 
 Returns indexes for the given items.
 @return Indexes of the givent items. 
 */
-(NSIndexSet*) browsingCacheIndexesForItems:(NSArray*)items;

@end
