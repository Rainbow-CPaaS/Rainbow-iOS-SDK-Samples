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

#import "ConferenceViewController.h"
#import "ParticipantTableViewCell.h"
#import "UIImage+Room.h"

@interface ConferenceViewController ()
@property (nonatomic, strong) ServicesManager *serviceManager;
@property (nonatomic, strong) ConferencesManagerService *conferencesManager;
@property (nonatomic, strong) NSMutableArray<ConferenceParticipant *> *participants;
@end

@implementation ConferenceViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _serviceManager = [ServicesManager sharedInstance];
        _conferencesManager = _serviceManager.conferencesManagerService;
        _participants = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc {
    _participants = nil;
    _serviceManager = nil;
    _conferencesManager = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateParticipants];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateConference:) name:kConferencesManagerDidUpdateConference object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConferencesManagerDidUpdateConference object:nil];
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

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        NSLog(@"Back pressed");
        [self.conferencesManager hangup:self.room completionHandler:^(NSError *error) {
            if (error){
                [self showErrorPopupWithTitle:@"Conference" message:@"Error while trying to hangup the conference"];
            }
        }];
    }
}

#pragma mark -

-(void) updateParticipants {
    [self.participants removeAllObjects];
    for(ConferenceParticipant *participant in self.room.conference.participants){
        if(participant.state == ParticipantStateConnected){
            [self.participants addObject:participant];
        }
    }
}

#pragma mark -

-(void) didUpdateConference:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didUpdateConference:notification];
        });
        return;
    }
    
    NSDictionary *userInfo = (NSDictionary *)notification.object;
    Room *room = [userInfo objectForKey: kRoomKey];
    
    NSLog(@"Conference '%@' was updated", room.conference.description);
    
    [self updateParticipants];
    
    if([self isViewLoaded]){
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.participants.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Participants";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ParticipantTableViewCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ParticipantTableViewCell *participantCell = (ParticipantTableViewCell *)cell;
    ConferenceParticipant *participant = self.participants[indexPath.row];
    if(participant){
        participantCell.name.text = participant.getDisplayName;
        participantCell.avatar.image = [UIImage avatarForContact:participant.getContact];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
