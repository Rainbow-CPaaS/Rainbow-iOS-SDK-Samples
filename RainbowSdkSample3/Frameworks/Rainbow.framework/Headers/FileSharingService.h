/*
 * Rainbow
 *
 * Copyright (c) 2017, ALE International
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
#import "File.h"
#import "Conversation.h"

FOUNDATION_EXPORT NSString *const kFileSharingServiceDidUpdateUploadedBytesSent;
FOUNDATION_EXPORT NSString *const kFileSharingServiceDidUpdateDownloadedBytes;
FOUNDATION_EXPORT NSString *const kFileSharingServiceDidUpdateFile;

typedef void (^FileSharingDataDownloadedComplionHandler) (File *file, NSError *error);
typedef void (^FileSharingDataUploadedComplionHandler) (File *file, NSError *error);
typedef void (^FileSharingMaxDataSizeComplionHandler) (NSUInteger maxChunkSizeDownload,NSUInteger maxChunkSizeUpload, NSError *error);
typedef void (^FileSharingDataRemoveViewerComplionHandler) (File *file, NSError *error);
typedef void (^FileSharingDataLoadSharedFilesWithPeerComplionHandler) (NSArray<File *> *files, NSError *error);
typedef void (^FileSharingRefreshSharedFileListComplionHandler) (NSArray<File *> *files , NSUInteger offset , NSUInteger total, NSError *error);

@interface FileSharingService : NSObject
// File sharing current consumption size (in octet)
@property (readonly) NSInteger currentSize;

// File sharing quota for the connected user value in GB
@property (readonly) NSInteger maxQuotaSize;

@property (readonly) NSArray<File *> *files;

-(File *) createTemporaryFileWithFileName:(NSString *) fileName andData:(NSData *) data andURL:(NSURL *)url;

-(void) downloadDataForFile:(File *) file withCompletionHandler:(FileSharingDataDownloadedComplionHandler) completionHandler;

-(void) downloadThumbnailDataForFile:(File *) file withCompletionHandler:(FileSharingDataDownloadedComplionHandler) completionHandler;

-(void) deleteFile:(File *) file;

-(void) loadSharedFilesWithPeer:(Peer *) peer fromOffset :(NSUInteger)offset completionHandler:(FileSharingDataLoadSharedFilesWithPeerComplionHandler)completionHandler;

-(void) removeViewer:(Peer *) peer fromFile:(File *) file completionHandler:(FileSharingDataRemoveViewerComplionHandler) completionHandler;

-(void) refreshSharedFileListFromOffset :(NSInteger)offset withLimit:(NSInteger)limit withCompletionHandler:(FileSharingRefreshSharedFileListComplionHandler) completionHandler;

-(void) fetchFileInformation:(File *) file;

-(File *) getFileByRainbowID:(NSString *) rainbowID;


@end
