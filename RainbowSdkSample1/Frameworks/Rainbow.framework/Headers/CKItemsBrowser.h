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
#import "CKBrowsableItem.h"

/** Block definition for asynchronous page browsing completion. 
 @param addedCacheItems An array of `CKBrowsableItem` instances that have been added to the browing cache during the browsing operation. 
 `nil` in case of error.  
 @param removedCacheItems An array of `CKBrowsableItem` instances that have been removed from browing cache during the browsing operation. 
 `nil` in case of error.
 @param updatedCacheItems An array of `CKBrowsableItem` instances that have been updated from browing cache during the browsing operation. 
 `nil` in case of error.
 @param error The error that may have occured while browsing. `nil` if no error during the browsing operation. */
typedef void(^CKItemsBrowsingCompletionHandler)(NSArray* addedCacheItems, NSArray* removedCacheItems, NSArray* updatedCacheItems, NSError* error);

@class CKItemsBrowser;

/**
 This protocol should be implemented by any object interested in events related to the 
 current browsing window / cache.
 */
@protocol CKItemsBrowserDelegate <NSObject>
#pragma mark - browsing window / cache updates.
/**
 Invoked when some items that are part of the browsing cache have been added (invoked in the main thread context).
 @param browser The browser informing the delegate of this event. 
 @param newItems The added items as an array of `CKBrowsableItem` instances.
 @param indexes A set of indexes describing where the items have been added in the browsing cache.
 */
-(void) itemsBrowser:(CKItemsBrowser*)browser didAddCacheItems:(NSArray*)newItems atIndexes:(NSIndexSet*)indexes;

/**
 Invoked when some items that are part of the browsing cache have been deleted (invoked in the main thread context).
 @param browser The browser informing the delegate of this event. 
 @param removedItems The removed items as an array of `CKBrowsableItem` instances.
 @param indexes A set of indexes describing where the items have been removed from the browsing cache.
 */
-(void) itemsBrowser:(CKItemsBrowser*)browser didRemoveCacheItems:(NSArray*)removedItems atIndexes:(NSIndexSet*)indexes;

/**
 Invoked when items that are part of the browsing cache have been updated: some of their attributes have been changed.
 @param browser The browser informing the delegate of this event. 
 @param changedItems Items from the browsing cache that have been updated.
 @param indexes A set of indexes describing where the items have been updated from the browsing cache.
 */
-(void) itemsBrowser:(CKItemsBrowser*)browser didUpdateCacheItems:(NSArray*)changedItems atIndexes:(NSIndexSet*)indexes;

/**
 Invoked when some items have been reorder in the browsing cache. This happens when the date of those browsable items have been 
 changed, so in order to keep the cache properly ordered, the browser has changed their indexes.
 @param browser The browser informing the delegate of this event. 
 @param oldIndexes Moved items old indexes.
 @param newIndexes Moved itmes new indexes.
 */
-(void) itemsBrowser:(CKItemsBrowser*)browser didReorderCacheItemsAtIndexes:(NSArray*)oldIndexes toIndexes:(NSArray*)newIndexes;

#pragma mark - added / removed / updated items events
/**
 Invoked when new items have been received (invoked in the main thread context).
 NB: when some new items are created on the fly, two selectors are invoked: this one, but also  
 `itemsBrowser:didAddCacheItems:atIndexes:` that describes how the change impacted the browsing cache. 
 @param browser The browser informing the delegate of this event.
 @param addedItems The deleted items as an array of `CKBrowsableItem` instances.
 */
@optional
-(void) itemsBrowser:(CKItemsBrowser*)browser didReceiveItemsAddedEvent:(NSArray*)addedItems;

/**
 Invoked when some items have been deleted (invoked in the main thread context).
 NB: when some items are deleted on the fly, two selectors are invoked: this one, but also  
 `itemsBrowser:didRemoveCacheItems:atIndexes:` that describes how the change impacted the browsing cache. 
 @param browser The browser informing the delegate of this event.
 @param deletedItems The deleted items as an array of `CKBrowsableItem` instances.
 @see itemsBrowser:didRemoveCacheItems:atIndexes:
 */
@optional
-(void) itemsBrowser:(CKItemsBrowser*)browser didReceiveItemsDeletedEvent:(NSArray*)deletedItems;

/**
 Invoked when ALL items have been deleted (invoked in the main thread context).
 NB: when ALL items are deleted, two selectos are invoked: this one, but also  
 `itemsBrowser:didRemoveCacheItems:atIndexes:` that describes how the change impacted the browsing cache. 
 @param browser The browser informing the delegate of this event.
 @see itemsBrowser:didRemoveCacheItems:atIndexes: 
 */
@optional
-(void) itemsBrowserDidReceivedAllItemsDeletedEvent:(CKItemsBrowser*)browser;

@end 

#pragma mark -

/**
 This class defines browsers that can be used to browse items (as defined in `CKBrowsableItem` protocol).
 The browsing is achieved by retrieving pages of items. 
 Browsers maintain a cache of browsed items (the browsing window).  
 **This class is thread safe**.
 */
@interface CKItemsBrowser : NSObject {
    BOOL _hasMorePages;
    /** Browsing page size. */
    NSInteger _itemsCountPerPage;
    
	/** Browsed items. */
    NSMutableArray* _browsingCache;
    
    NSOperationQueue* _browsingJobsQueue;
    /** */
    NSMutableArray* _pendingBrowsingJobs;
    /** Ensure thread safe access to this object attributes. */
    NSObject* _itemsMutex;
    
    @protected
    id<CKItemsBrowserDelegate> _delegate;
}
/** @name Properties */

/** This browser's delegate. Use it to be informed of events impacting the current browsing window: added / removed / updated items. */
@property (readwrite, assign) id <CKItemsBrowserDelegate> delegate;
/** Maximum number of items per browsing page. */
@property (readonly) NSInteger itemsCountPerPage;
/** This browser's cache as an array of `CKBrowsableItem` instances. */
@property (readonly) NSArray* browsingCache;

-(instancetype) initWithItemsCountPerPage:(NSInteger)itemsPerPage; 

#pragma mark - Cache maintenance
/** @name Cache maintenance */
/** Resets this browser instance: cache is cleaned, browsing window is reset. The state 
 of the browser after this is the same as it would be as after creation. */ 
-(void) reset;

/** Removes from cache all items older than the given date. 
 @return An array of deleted `CKBrowsableItem` instances that have been removed from the browsing cache. */
-(NSArray*) removeCacheItemsBeforeDate:(NSDate*)limitDate;

/** Removes from cache all item after the given index (included).
 @return An array of deleted `CKBrowsableItem` instances that have been removed from the browsing cache. */
-(NSArray*) removeCacheItemsFromIndex:(NSInteger)idx; 

/** Removes an item from the cache at the specified index.
 @return The item that has been removed from the cache. */
-(id<CKBrowsableItem>) removeCacheItemAtIndex:(NSInteger)idx;

/** Returns the cache item identified by its reference identifier.
 @return The cache item identified by its reference identifier. `nil` is returned if no 
 item matches the given reference identifier. */
-(id<CKBrowsableItem>) getCacheItemWithReferenceIdentifier:(NSString*)refIdentifier;

#pragma mark - Pages retrieval 
/** @name Pages retrieval */

/** Returns `YES` if this browser may have more items to browse. 
 @return Returns `YES` if this browser may have more items to browse. `NO` if the end of items have been reached. */
-(BOOL) hasMorePages;

/** Asynchronous retrieving of the next browsing page. 
 @param completionHandler Completion block invoked when the next page has been retrieved. `nil` if you're not 
 interested in asynchronous feedback.
 **This block is invoked in the context of main thread.** */
-(void) nextPageWithCompletionHandler:(CKItemsBrowsingCompletionHandler)completionHandler;

#pragma mark - Resyncing cache 
/** @name Resyncing cache */

/** Resyncs current browsing cache asynchronously until the given date.
 This retrieves once again all pages to get all items until the given date and updates the cache according
 to those "fresh" pages.
 @param date The date until the cache should be resynced (items with date equals to this parameter are also updated).
 @param completionHandler Completion block invoked when the next page has been retrieved. `nil` if you're not 
 interested in asynchronous feedback. */
-(void) resyncBrowsingCacheUntilDate:(NSDate*)date withCompletionHandler:(CKItemsBrowsingCompletionHandler)completionHandler;

/** Resyncs current browsing cache asynchronously. This will check if the cache is still up to date and in case
 it is not, will update it so that it reflects current items state.
 @param completionHandler Completion block invoked when the next page has been retrieved. `nil` if you're not 
 interested in asynchronous feedback.
 **This block is invoked in the context of main thread.** */
-(void) resyncBrowsingCacheWithCompletionHandler:(CKItemsBrowsingCompletionHandler)completionHandler;

@end
