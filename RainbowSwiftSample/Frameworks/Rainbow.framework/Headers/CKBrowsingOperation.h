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

@interface CKBrowsingOperation : NSOperation {
    BOOL _outdated;
    
    NSInteger _startIndex;
    NSInteger _itemsCount;
    
    NSArray* _jobResultPage;
    NSError* _jobResultError;
}

@property (readwrite) BOOL outdated;
@property (readwrite) NSInteger startIndex;
@property (readwrite) NSInteger itemsCount;
@property (readonly) NSArray* jobResultPage;
@property (readonly) NSError* jobResultError;
@property (readwrite) BOOL hasMorePages;

/* The timeframe start covered by this browsing operation. OLDEST */
@property (readonly) NSDate* timeFrameStart;
/* The timeframe end covered by this browsing operation. NEWEST. `nil` if items returned by this operation go to "NOW" */
@property (readonly) NSDate* timeFrameEnd;

/** Performs the job and returns found browsed items as an array. */
-(NSArray*) performJobWithError:(NSError**)error;

@end

