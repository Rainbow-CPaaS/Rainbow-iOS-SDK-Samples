/*
 * Rainbow SDK sample
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

#import "ReceivedFilesTableViewController.h"
#import <Rainbow/Rainbow.h>

@interface ReceivedFilesTableViewController ()
@property (strong, nonatomic) NSArray<File *> *sharedFiles;

@property (strong, nonatomic) FileSharingService *fileSharingService;
@end

@implementation ReceivedFilesTableViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _fileSharingService = [ServicesManager sharedInstance].fileSharingService;
        _sharedFiles = @[];
    }
    return self;
}

-(void)dealloc {
    _fileSharingService = nil;
    _sharedFiles = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.fileSharingService fetchMyReceivedFilesFromOffset:0 withLimit:500 withTypeMIME:FilterFilesAll withSortField:FileSortFieldDate withCompletionHandler:^(NSArray<File *> *files, NSUInteger total, NSError *error) {
        if(error){
            NSLog(@"Error while loading shared files: %@", [error localizedDescription]);
        } else {
            self.sharedFiles = files;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sharedFiles.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Shared files";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView dequeueReusableCellWithIdentifier:@"DetailTableViewCell" forIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    File *file = _sharedFiles[indexPath.row];
    cell.textLabel.text = file.fileName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Type: %@  Size: %lu", file.mimeType, file.size];
    if(file.thumbnailData){
        cell.imageView.image = [UIImage imageWithData:file.thumbnailData scale:1.0];
        CGSize itemSize = CGSizeMake(40, 40);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
