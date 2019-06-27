//
//  MyRainbowSharingTableViewController.m
//  RainbowiOSSDKFileSharing
//
//  Created by Vladimir Vyskocil on 26/06/2019.
//  Copyright © 2019 ALE. All rights reserved.
//

#import "MyRainbowSharingTableViewController.h"
#import <Rainbow/Rainbow.h>

@interface MyRainbowSharingTableViewController ()
@property (nonatomic, weak) IBOutlet UILabel *quotaValue;

@property (strong, nonatomic) FileSharingService *fileSharingService;
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
    
    [self.fileSharingService refreshSharedFileListFromOffset:0 withLimit:500 withTypeMIME:FilterFilesAll withCompletionHandler:^(NSArray<File *> *files, NSUInteger offset, NSUInteger total, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
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
    return self.fileSharingService.files.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Files";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView dequeueReusableCellWithIdentifier:@"MyRainbowSharingTableViewCell" forIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    File *file = self.fileSharingService.files[indexPath.row];
    cell.textLabel.text = file.fileName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Type: %@  Size: %lu", file.mimeType, file.size];
}

@end
