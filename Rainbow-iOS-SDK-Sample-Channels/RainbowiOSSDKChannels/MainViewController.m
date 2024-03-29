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
#import "ChannelTableViewCell.h"
#import "ItemTableViewCell.h"
#import "LoginViewController.h"
#import "PostItemViewController.h"
#import "ChannelInfoViewController.h"

@interface MainViewController ()
@property (nonatomic, weak) IBOutlet UITableView *channelsListView;
@property (nonatomic, weak) IBOutlet UITableView *itemsListView;
@property (weak, nonatomic) IBOutlet UIButton *postItemButton;

@property (nonatomic, strong) ChannelsService *channelsManager;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, strong) NSArray<ChannelItem *> *itemsInChannel;
@end

@implementation MainViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _channelsManager = [ServicesManager sharedInstance].channelsService;
        _selectedIndex = nil;
        _itemsInChannel = [NSArray new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddChannel:) name:kChannelsServiceDidAddChannel object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveChannel:) name:kChannelsServiceDidRemoveChannel object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateChannel:) name:kChannelsServiceDidUpdateChannel object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveItem:) name: kChannelsServiceDidReceiveNewItem object:nil];
    }
    return self;
}

-(void)dealloc {
    _channelsManager = nil;
    _selectedIndex = nil;
    _itemsInChannel = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChannelsServiceDidAddChannel object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChannelsServiceDidRemoveChannel object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChannelsServiceDidUpdateChannel object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name: kChannelsServiceDidReceiveNewItem object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _postItemButton.enabled = _selectedIndex ? YES : NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_selectedIndex) {
        [self getItemsInSelectedChannel];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"BackToLoginSegue"]){
        LoginViewController *loginViewController = (LoginViewController *)segue.destinationViewController;
        loginViewController.doLogout = YES;
    } else if ([segue.identifier isEqualToString:@"PostItemSegue"]){
        if(_selectedIndex){
            Channel *channel = [_channelsManager.channels objectAtIndex:self.selectedIndex.row];
            PostItemViewController *postItemViewController = (PostItemViewController *)segue.destinationViewController;
            postItemViewController.channel = channel;
        }
    } else if ([segue.identifier isEqualToString:@"ChannelInfoSegue"]){
        if(_selectedIndex){
            Channel *channel = [_channelsManager.channels objectAtIndex:self.selectedIndex.row];
            ChannelInfoViewController *channelInfoViewController = (ChannelInfoViewController *)segue.destinationViewController;
            channelInfoViewController.channel = channel;
        }
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

-(void) didReceiveItem :(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didReceiveItem:notification];
        });
        return;
    }
    ChannelItem *item = notification.object;
    Channel *channel = [_channelsManager getChannel:item.channelId];
    [self getItemsInChannel: channel];
    [_itemsListView reloadData];
}

#pragma mark - IBAction

- (IBAction)logout:(id)sender {
    [self performSegueWithIdentifier:@"BackToLoginSegue" sender:self];
}

- (IBAction)channelInfoAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.channelsListView];
    NSIndexPath *indexPath = [self.channelsListView indexPathForRowAtPoint:buttonPosition];
    if(indexPath){
        self.selectedIndex = indexPath;
        [self performSegueWithIdentifier:@"ChannelInfoSegue" sender:self];
    }
}


#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)getItemsInChannel:(Channel *)channel {
    [_channelsManager fetchItemsForChannel:channel beforeDate:nil number:20 completionHandler:^(NSArray<ChannelItem *> *items, NSError *error) {
        if (error) {
            NSLog(@"[getItemsInChannel] Error: %@", error.localizedDescription);
        } else {
            self.itemsInChannel = items;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.itemsListView reloadData];
            });
        }
    }];
}

-(void)getItemsInSelectedChannel {
    if(_selectedIndex){
        Channel *channel = [_channelsManager.channels objectAtIndex:self.selectedIndex.row];
        [self getItemsInChannel:channel];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Channels list view
    if(tableView == self.channelsListView){
        return _channelsManager.channels.count;
        
    // Channel items list view
    } else if(tableView == self.itemsListView){
        return _itemsInChannel.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // Channels list view
    if(tableView == self.channelsListView){
        cell = [self.channelsListView dequeueReusableCellWithIdentifier:@"ChannelTableViewCell" forIndexPath:indexPath];
        
    // Channel items list view
    } else if(tableView == self.itemsListView){
        cell = [self.itemsListView dequeueReusableCellWithIdentifier:@"ItemTableViewCell" forIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Channels list view
    if(tableView == self.channelsListView && indexPath.row < _channelsManager.channels.count){
        // We have to check the bounds because when a channel is removed using swipe to delete
        // the reloadData is called asynchronously and may not yet been called
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
        
    // Channel items list view
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
                
                // Show the item title if any
                if(item.title){
                    itemCell.title.text = item.title;
                    itemCell.title.hidden = NO;
                } else {
                    itemCell.title.hidden = YES;
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
    
    // Channels list view
    if(tableView == self.channelsListView){
        self.selectedIndex = indexPath;
        [self getItemsInSelectedChannel];
        [_itemsListView reloadData];
        _postItemButton.enabled = YES;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        Channel *channel = [_channelsManager.channels objectAtIndex:indexPath.row];
        [_channelsManager deleteChannel:channel.id completionHandler:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView reloadData];
            });
        }];
    }
}

@end
