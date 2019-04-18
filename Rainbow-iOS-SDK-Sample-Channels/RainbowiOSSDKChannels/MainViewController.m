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

#import "MainViewController.h"
#import <Rainbow/Rainbow.h>
#import <Rainbow/ChannelsService.h>
#import "ChannelTableViewCell.h"
#import "ItemTableViewCell.h"

#import <Contacts/Contacts.h>
#import <Rainbow/ContactsManagerService.h>
#import "LoginViewController.h"

@interface MainViewController ()
@property (nonatomic, weak) IBOutlet UITableView *channelsListView;
@property (nonatomic, weak) IBOutlet UITableView *itemsListView;

@property (nonatomic, strong) ServicesManager *serviceManager;
@property (nonatomic, strong) ChannelsService *channelsManager;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, strong) NSMutableArray<ChannelItem *> *itemsInChannel;
@end

@implementation MainViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _serviceManager = [ServicesManager sharedInstance];
        _channelsManager = _serviceManager.channelsService;
        _selectedIndex = nil;
        _itemsInChannel = [NSMutableArray new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddChannel:) name:kChannelsServiceDidAddChannel object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveChannel:) name:kChannelsServiceDidRemoveChannel object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateChannel:) name:kChannelsServiceDidUpdateChannel object:nil];
    }
    return self;
}

-(void)dealloc {
    _serviceManager = nil;
    _channelsManager = nil;
    _selectedIndex = nil;
    _itemsInChannel = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChannelsServiceDidAddChannel object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChannelsServiceDidRemoveChannel object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChannelsServiceDidUpdateChannel object:nil];
}

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"BackToLoginSegue"]){
        LoginViewController *loginViewController = (LoginViewController *)segue.destinationViewController;
        loginViewController.doLogout = YES;
    }
}

#pragma mark - Notifications channels management

-(void) didAddChannel:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddChannel:notification];
        });
        return;
    }
    [_channelsListView reloadData];
}

-(void) didRemoveChannel:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didRemoveChannel:notification];
        });
        return;
    }
    [_channelsListView reloadData];
}

-(void) didUpdateChannel:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didUpdateChannel:notification];
        });
        return;
    }
    [_channelsListView reloadData];
}

#pragma mark - IBAction

- (IBAction)logout:(id)sender {
    [self performSegueWithIdentifier:@"BackToLoginSegue" sender:self];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)getItemsInSelectedChannel {
    @synchronized (self) {
        [self.itemsInChannel removeAllObjects];
        if(_selectedIndex){
            Channel *channel = [_channelsManager.channels objectAtIndex:self.selectedIndex.row];
            for(ChannelItem *item in _channelsManager.channelsItems){
                if([item.channelId isEqualToString:channel.id]){
                    [_itemsInChannel addObject:item];
                }
            }
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.channelsListView){
        return _channelsManager.channels.count;
    } else if(tableView == self.itemsListView){
        return _itemsInChannel.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if(tableView == self.channelsListView){
        cell = [self.channelsListView dequeueReusableCellWithIdentifier:@"ChannelTableViewCell" forIndexPath:indexPath];
    } else if(tableView == self.itemsListView){
        cell = [self.itemsListView dequeueReusableCellWithIdentifier:@"ItemTableViewCell" forIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.channelsListView){
        ChannelTableViewCell *channelCell = (ChannelTableViewCell *)cell;
        Channel *channel = [_channelsManager.channels objectAtIndex:indexPath.row];
        if(channel){
            channelCell.name.text = channel.name;
            channelCell.topic.text = channel.channelDescription;
            if(channel.photoData){
                channelCell.avatar.image = [UIImage imageWithData: channel.photoData];
                channelCell.avatar.tintColor = [UIColor clearColor];
            } else {
                channelCell.avatar.image = [UIImage imageNamed:@"Default_Avatar"];
                channelCell.avatar.tintColor = [UIColor colorWithHue:(indexPath.row*36%100)/100.0 saturation:1.0 brightness:1.0 alpha:1.0];
            }
        }
    }  else if(tableView == self.itemsListView){
        ItemTableViewCell *itemCell = (ItemTableViewCell *)cell;
        if(self.selectedIndex){
            ChannelItem *item = [_itemsInChannel objectAtIndex:indexPath.row];
            if(item){
                if(item.type == ChannelItemTypeHtml){
                    [itemCell.html loadHTMLString:item.message baseURL:nil];
                    itemCell.text.hidden = YES;
                    itemCell.html.hidden = NO;
                } else if(item.type == ChannelItemTypeBasic){
                    itemCell.text.text = item.message;
                    itemCell.text.hidden = NO;
                    itemCell.html.hidden = YES;
                }
                
                // Show the first image if any
                if(item.images && item.images.count > 0){
                    itemCell.image.hidden = NO;
                    itemCell.image.image = ((ChannelItemImage *)[item.images firstObject]).image;
                } else {
                    itemCell.image.hidden = YES;
                }
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.channelsListView){
        self.selectedIndex = indexPath;
        [self getItemsInSelectedChannel];
        [_itemsListView reloadData];
    }
}

@end
