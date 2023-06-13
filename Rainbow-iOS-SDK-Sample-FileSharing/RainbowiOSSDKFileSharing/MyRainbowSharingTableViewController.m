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


#import "MyRainbowSharingTableViewController.h"
#import <Rainbow/Rainbow.h>

@interface MyRainbowSharingTableViewController ()
@property (nonatomic, weak) IBOutlet UILabel *quotaValue;

@property (strong, nonatomic) FileSharingService *fileSharingService;
@property (strong, nonatomic) NSArray<File *> *sharedFiles;
@end

@implementation MyRainbowSharingTableViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _fileSharingService = [ServicesManager sharedInstance].fileSharingService;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.fileSharingService fetchMyFilesFromOffset:0 withLimit:500 withTypeMIME:FilterFilesAll withSortField:FileSortFieldDate withCompletionHandler:^(NSArray<File *> *files, NSUInteger total, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sharedFiles = files;
            [self.tableView reloadData];
        });
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.quotaValue.text = [NSString stringWithFormat:@"%ldMB / %ldGB", self.fileSharingService.currentSize/(1024*1024), self.fileSharingService.maxQuotaSize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sharedFiles.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Files";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView dequeueReusableCellWithIdentifier:@"MyRainbowSharingTableViewCell" forIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    File *file = self.sharedFiles[indexPath.row];
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

@end
