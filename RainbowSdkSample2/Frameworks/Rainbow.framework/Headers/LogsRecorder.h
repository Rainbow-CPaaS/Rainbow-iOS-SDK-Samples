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

@interface LogsRecorder : NSObject {
	NSFileHandle* _fileHandle;
	NSString* _fileName;
	BOOL _isRecording;
    int stderrSave;
}

+(LogsRecorder*) sharedInstance;

-(void) startRecord;
-(void) stopRecord;
-(BOOL) isRecording;

/** Returns logs sorted by date. Most fresh = first item. */
-(NSArray*) logs;

// Remove logs file older than 7 days.
-(void) cleanOldLogs;

-(NSInteger) deleteAllLogs;
-(BOOL) deleteLog:(NSString*)trackName;
-(NSArray*) deleteLogsBefore:(NSDate*)date;
-(NSDictionary*) attributes:(NSString*) trackName ;
-(NSData*) dataForLog:(NSString*)trackName;
-(NSURL *) zippedApplicationLogs;
@end
