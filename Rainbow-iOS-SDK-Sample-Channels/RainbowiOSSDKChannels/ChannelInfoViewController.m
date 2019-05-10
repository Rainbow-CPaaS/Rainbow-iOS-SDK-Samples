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

@interface ChannelInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *closedOrPublicSwitch;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UITableView *subscribersList;

@end

@implementation ChannelInfoViewController

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
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
