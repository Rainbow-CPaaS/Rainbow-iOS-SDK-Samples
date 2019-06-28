//
//  ReceivedFilesTableViewController.m
//  RainbowiOSSDKFileSharing
//
//  Created by Vladimir Vyskocil on 26/06/2019.
//  Copyright © 2019 ALE. All rights reserved.
//

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
    
    [self.fileSharingService loadSharedFilesWithPeer:nil fromOffset:0 completionHandler:^(NSArray<File *> *files, NSError *error) {
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

@end
