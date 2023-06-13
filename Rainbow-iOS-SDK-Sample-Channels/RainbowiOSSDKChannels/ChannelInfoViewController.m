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

#import "ChannelInfoViewController.h"
#import "ChannelUserTableViewCell.h"
#import <Rainbow/Rainbow.h>

@interface ChannelInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *closedOrPublicSwitch;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UITableView *subscribersList;

@property (nonatomic, strong) ChannelsService *channelsManager;
@property (strong, nonatomic) NSArray<ChannelUser *> *channelUsers;
@end

@implementation ChannelInfoViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _channelsManager = [ServicesManager sharedInstance].channelsService;
        _channelUsers = [NSArray new];
    }
    return self;
}

-(void)dealloc {
    _channelsManager = nil;
    _channelUsers = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.channel){
        if(self.channel.photoData){
            self.avatarImageView.image = [UIImage imageWithData: self.channel.photoData];
        } else {
            self.avatarImageView.image = [UIImage imageNamed:@"Default_Avatar"];
        }
        self.titleLabel.text = self.channel.name;
        self.descriptionLabel.text = self.channel.channelDescription;
        if([self.channel.category length] > 0){
            self.categoryLabel.text = self.channel.category;
        } else {
            self.categoryLabel.text = @"Not set";
        }
        if(self.channel.mode == ChannelModeCompanyClosed){
            self.closedOrPublicSwitch.selectedSegmentIndex = 0;
        } else if(self.channel.mode == ChannelModeCompanyPublic){
            self.closedOrPublicSwitch.selectedSegmentIndex = 1;
        }
        
        [self.channelsManager fetchUsersFromChannel:self.channel filterType:ChannelUserFilterTypeAll offset:0 count:16 withBlock:^(NSArray<ChannelUser *> *users, int total, NSError *error) {
            if(error){
                NSLog(@"getFirstUsersFromChannel returned a error: %@", [error localizedDescription]);
            } else {
                self.channelUsers = users;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.subscribersList reloadData];
                });
            }
        }];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channelUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChannelUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelUserTableViewCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ChannelUserTableViewCell *channelUserCell = (ChannelUserTableViewCell *)cell;
    channelUserCell.name.text = self.channelUsers[indexPath.row].contact.displayName;
}

@end
