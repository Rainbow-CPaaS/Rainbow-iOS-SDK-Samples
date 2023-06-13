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
#import "RoomTableViewCell.h"
#import "UIImage+Room.h"
#import "LoginViewController.h"
#import "CallViewController.h"
#import "ConferenceViewController.h"

@interface MainViewController ()
@property (nonatomic, strong) ServicesManager *serviceManager;
@property (nonatomic, strong) RoomsService *roomsManager;
@property (nonatomic, strong) NSMutableArray<Room *> *myRooms;
@property (nonatomic, strong) NSMutableArray<Room *> *invitedRooms;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@end

@implementation MainViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _serviceManager = [ServicesManager sharedInstance];
        _roomsManager = _serviceManager.roomsService;
        _myRooms = [[NSMutableArray alloc] init];
        _invitedRooms = [[NSMutableArray alloc] init];
        _selectedIndex = nil;
    }
    return self;
}

-(void)dealloc {
    _myRooms = nil;
    _invitedRooms = nil;
    _serviceManager = nil;
    _roomsManager = nil;
    _selectedIndex = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPopulatingMyNetwork:) name:kContactsManagerServiceDidEndPopulatingMyNetwork object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddRoom:) name:kRoomsServiceDidAddRoom object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateRoom:) name:kRoomsServiceDidUpdateRoom object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveRoom:) name:kRoomsServiceDidRemoveRoom object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRoomsServiceDidAddRoom object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRoomsServiceDidUpdateRoom object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRoomsServiceDidRemoveRoom object:nil];
}

-(void) insertRoom:(Room *) room {
    if(room.isMyRoom){
        if (![_myRooms containsObject:room]) {
            [_myRooms addObject:room];
        } else {
            NSUInteger index =  [_myRooms indexOfObjectIdenticalTo:room];
            if (index != NSNotFound) {
                [_myRooms replaceObjectAtIndex:index withObject:room];
            }
        }
    } else {
        if (![_invitedRooms containsObject:room]) {
            [_invitedRooms addObject:room];
        } else {
            NSUInteger index =  [_invitedRooms indexOfObjectIdenticalTo:room];
            if (index != NSNotFound) {
                [_invitedRooms replaceObjectAtIndex:index withObject:room];
            }
        }
        
    }
}

-(BOOL) removeRoom:(Room *)room {
    BOOL removed = NO;
    if(room.isMyRoom){
        if([self.myRooms containsObject:room]){
            [self.myRooms removeObject:room];
            removed = YES;
        }
    } else {
        if([self.invitedRooms containsObject:room]){
            [self.invitedRooms removeObject:room];
            removed = YES;
        }
    }
    return removed;
}

-(void) didEndPopulatingMyNetwork:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didEndPopulatingMyNetwork:notification];
        });
        return;
    }
    NSLog(@"[MainViewController] Did end populating my network");
    
    for(Room *room in _roomsManager.rooms) {
        // Add room to the list either :
        // - When this is my room and it isn't archived (room.myStatusInRoom != ParticipantStatusUnsubscribed)
        // - When I accepted the invitation to the room and the conference has been started
        if((room.isMyRoom && room.myStatusInRoom != ParticipantStatusUnsubscribed) ||
           (room.myStatusInRoom == ParticipantStatusAccepted && room.conference.isActive)){
            [self insertRoom:room];
        }
    }
    if([self isViewLoaded])
        [self.tableView reloadData];
}

-(void) didAddRoom:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddRoom:notification];
        });
        return;
    }
    
    Room *room = notification.object;
    if((room.isMyRoom && room.myStatusInRoom != ParticipantStatusUnsubscribed) ||
       (room.myStatusInRoom == ParticipantStatusAccepted && room.conference.isActive)){
        [self insertRoom:room];
        [self.roomsManager fetchRoomDetails:room];
        
        if([self isViewLoaded])
            [self.tableView reloadData];
    }
}

-(void) didRemoveRoom:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didRemoveRoom:notification];
        });
        return;
    }
    
    Room *room = notification.object;
    BOOL reload = [self removeRoom:room];

    if(reload && [self isViewLoaded]){
        [self.tableView reloadData];
    }
    
}

-(void) didUpdateRoom:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didUpdateRoom:notification];
        });
        return;
    }
    
    NSDictionary *userInfo = (NSDictionary *)notification.object;
    Room *room = [userInfo objectForKey:kRoomKey];
    
    [self removeRoom:room];
    if((room.isMyRoom && room.myStatusInRoom != ParticipantStatusUnsubscribed) ||
       (room.myStatusInRoom == ParticipantStatusAccepted && room.conference.isActive)){
        [self insertRoom:room];
    }

    if([self isViewLoaded]){
        [self.tableView reloadData];
    }
}

#pragma mark - Segue navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"ConferenceSegue"]){
        ConferenceViewController *vc = segue.destinationViewController;
       if(self.selectedIndex){
           if(self.selectedIndex.section == 0){
               vc.room = [self.myRooms objectAtIndex:self.selectedIndex.row];
           } else {
               vc.room = [self.invitedRooms objectAtIndex:self.selectedIndex.row];
           }
        }
    } else if ([segue.identifier isEqualToString: @"BackToLoginSegue"]){
        LoginViewController *loginViewController = (LoginViewController *)segue.destinationViewController;
        loginViewController.doLogout = YES;
    }
}

#pragma mark -

- (void) showErrorPopupWithTitle:(NSString *) title message:(NSString *) message {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showErrorPopupWithTitle:title message:message];
        });
        return;
    }
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [menu dismissViewControllerAnimated:YES completion:nil];
    }];
    [menu addAction:ok];
   
    [self presentViewController:menu animated:YES completion:nil];
}

-(void)joinConferenceInRoom:(Room *)room {
    ParticipantRole role = room.conference.isMyConference ? ParticipantRoleModerator : ParticipantRoleMember;
    [[ServicesManager sharedInstance].conferencesManagerService startAndJoinConferenceWithRoom:room role:role completionBlock:^(NSError *error) {
        if(error){
            [self showErrorPopupWithTitle:@"Conference" message:@"Error while trying to join the conference"];
        }
    }];
}

#pragma mark - IBAction

- (IBAction)logout:(id)sender {
    [self performSegueWithIdentifier:@"BackToLoginSegue" sender:self];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.myRooms.count > 0 ? 1 : 0) + (self.invitedRooms > 0 ? 1 : 0);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return self.myRooms.count;
    } else {
        return self.invitedRooms.count;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return @"My rooms";
    } else {
        return @"Conference rooms where I'm invited";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RoomTableViewCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomTableViewCell *roomCell = (RoomTableViewCell *)cell;
    Room *room =  indexPath.section == 0 ? [self.myRooms objectAtIndex:indexPath.row] : [self.invitedRooms objectAtIndex:indexPath.row];
    if(room){
        roomCell.name.text = room.displayName;
        roomCell.topic.text = room.topic;
        roomCell.avatar.image = [UIImage avatarForRoom:room];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"Join conference" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *call = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Room *room = (Room *)(indexPath.section == 0 ? [self.myRooms objectAtIndex:indexPath.row] : [self.invitedRooms objectAtIndex:indexPath.row]);
        [self performSegueWithIdentifier:@"ConferenceSegue" sender:self];
        [self joinConferenceInRoom:room];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [menu addAction:call];
    [menu addAction:cancel];
    [self presentViewController:menu animated:YES completion:nil];
}

@end
