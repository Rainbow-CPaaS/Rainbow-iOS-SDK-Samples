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

#import "DetailViewController.h"
#import <Rainbow/Rainbow.h>

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UITableView *infoList;

@property (strong, nonatomic) NSArray<File *> *sharedFiles;

@property (strong, nonatomic) FileSharingService *fileSharingService;
@end

@implementation DetailViewController

-(void)awakeFromNib {
    [super awakeFromNib];
    
    _fileSharingService = [ServicesManager sharedInstance].fileSharingService;
    _sharedFiles = @[];
}

-(void)dealloc {
    _fileSharingService = nil;
    _sharedFiles = nil;
}

-(void)updateUI {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
        });
        return;
    }
    self.nameLabel.text = self.contact.fullName;
    self.companyLabel.text = self.contact.companyName;
    if(self.contactImage){
        self.avatar.image = self.contactImage;
        if(self.contactImageTint){
            self.avatar.tintColor = self.contactImageTint;
        }
    }
    
    [self.infoList reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.fileSharingService loadSharedFilesWithPeer:self.contact fromOffset:0 completionHandler:^(NSArray<File *> *files, NSError *error) {
        if(error){
            NSLog(@"Error while loading shared files: %@", [error localizedDescription]);
        } else {
            self.sharedFiles = files;
        }
        [self updateUI];
    }];
}

#pragma mark - UITableViewDataSource

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
