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
#import <Contacts/Contacts.h>
#import <Rainbow/ContactsManagerService.h>
#import "ContactTableViewCell.h"
#import "LoginViewController.h"
#import "CallViewController.h"

@interface MainViewController ()
@property (nonatomic, strong) ServicesManager *serviceManager;
@property (nonatomic, strong) ContactsManagerService *contactsManager;
@property (nonatomic, strong) NSMutableArray<Contact *> *allObjects;
@property (nonatomic) BOOL populated;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic) BOOL isVideoCall;
@property (nonatomic, strong) RTCCall *call;
@end

@implementation MainViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _serviceManager = [ServicesManager sharedInstance];
        _contactsManager = _serviceManager.contactsManagerService;
        _allObjects = [[NSMutableArray alloc] init];
        _populated = NO;
        _selectedIndex = nil;
    }
    return self;
}

-(void)dealloc {
    _allObjects = nil;
    _serviceManager = nil;
    _contactsManager = nil;
    _selectedIndex = nil;
}

-(void)setMyUserAvatar {
    UIView *avatarView = [[UIView alloc] initWithFrame: CGRectMake(0,0,40,40)];
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0,0,40,40)];
    avatarImageView.layer.cornerRadius = 20;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.contentMode =  UIViewContentModeScaleAspectFit;
    if(_serviceManager.myUser.contact.photoData){
        avatarImageView.image = [UIImage imageWithData: _serviceManager.myUser.contact.photoData];
    } else {
        avatarImageView.image = [UIImage imageNamed:@"Default_Avatar"];
    }
    [avatarView addSubview:avatarImageView];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView: avatarImageView];
    [NSLayoutConstraint activateConstraints: @[[barButton.customView.widthAnchor constraintEqualToConstant:40]  ,[barButton.customView.heightAnchor constraintEqualToConstant:40]]];
    self.navigationItem.leftBarButtonItem = barButton;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _call = nil;
    
    [self setMyUserAvatar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPopulatingMyNetwork:) name:kContactsManagerServiceDidEndPopulatingMyNetwork object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddContact:) name:kContactsManagerServiceDidAddContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateContact:) name:kContactsManagerServiceDidUpdateContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveContact:) name:kContactsManagerServiceDidRemoveContact object:nil];
    // RTC call notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateCall:) name:kTelephonyServiceDidUpdateCall object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddCall:) name:kTelephonyServiceDidAddCall object:nil];
    if(!_populated) {
        [self didEndPopulatingMyNetwork:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidAddContact object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidUpdateContact object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidRemoveContact object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidEndPopulatingMyNetwork object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTelephonyServiceDidUpdateCall object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTelephonyServiceDidAddCall object:nil];
}

-(void) insertContact:(Contact *) contact {
    // Only handle RainbowContact not ExternalContact, LocalContact,...
    if (contact.class != RainbowContact.class) {
        return;
    }
    RainbowContact *rainbowContact = (RainbowContact *)contact;
    
    // Ignore myself
    if (rainbowContact.isMe) {
        return;
    }
    // Ignore bots
    if(rainbowContact.isBot) {
        return;
    }
    // Ignore contact not in the roster
    if(!rainbowContact.isInRoster){
        return;
    }
    
    if (![_allObjects containsObject:contact]) {
        [_allObjects addObject:contact];
    } else {
        NSUInteger index =  [_allObjects indexOfObjectIdenticalTo:contact];
        if (index != NSNotFound) {
            [_allObjects replaceObjectAtIndex:index withObject:contact];
        }
    }
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
    
    for(Contact *contact in _contactsManager.contacts) {
        [self insertContact:contact];
    }
    if([self isViewLoaded])
        [self.tableView reloadData];
    _populated = YES;
}

-(void) didAddContact:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddContact:notification];
        });
        return;
    }
    
    Contact *contact = notification.object;
    [self insertContact:contact];
    
    if([self isViewLoaded] && _populated)
        [self.tableView reloadData];
}

-(void) didRemoveContact:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didRemoveContact:notification];
        });
        return;
    }
    
    Contact *contact = notification.object;
    if([self.allObjects containsObject:contact]){
        [self.allObjects removeObject:contact];
        
        if([self isViewLoaded] && _populated)
            [self.tableView reloadData];
    }
}

-(void) didUpdateContact:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didUpdateContact:notification];
        });
        return;
    }
    
    NSDictionary *userInfo = (NSDictionary *)notification.object;
    Contact *contact = [userInfo objectForKey:kContactKey];
    
    if (contact.class == RainbowContact.class) {
        RainbowContact *rainbowContact = (RainbowContact *)contact;
        
        if (rainbowContact.isInRoster){
            [self insertContact:rainbowContact];
            
        } else {
            if ([_allObjects containsObject:rainbowContact]) {
                [_allObjects removeObject:rainbowContact];
            }
        }
        
        if([self isViewLoaded] && _populated){
            [self.tableView reloadData];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"CallInProgressSegue"]){
        CallViewController *vc = segue.destinationViewController;
        if(self.selectedIndex){
            vc.contact = (RainbowContact *)[self.allObjects objectAtIndex:self.selectedIndex.row];
            vc.contactImage = ((ContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndex]).avatar.image;
            vc.contactImageTint = ((ContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndex]).avatar.tintColor;
            vc.isIncoming = NO;
            vc.isVideoCall = self.isVideoCall;
        } else {
            vc.isIncoming = YES;
            vc.currentCall = self.call;
        }
    } else if ([segue.identifier isEqualToString: @"BackToLoginSegue"]){
        LoginViewController *loginViewController = (LoginViewController *)segue.destinationViewController;
        loginViewController.doLogout = YES;
    }
}

#pragma mark - RTC call handling

-(void)didUpdateCall:(NSNotification *)notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didUpdateCall:notification];
        });
        return;
    }
    
    if([notification.object class] == [RTCCall class]){
        RTCCall *call = (RTCCall *) notification.object;
        NSLog(@"didUpdateCall notification, call status: %@", [Call stringForStatus:call.status]);
    }
}

-(void)didAddCall:(NSNotification *)notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddCall:notification];
        });
        return;
    }
    
    if([notification.object class] == [RTCCall class]){
        RTCCall *call = (RTCCall *) notification.object;
        NSLog(@"didAddCall notification, call status: %@", [Call stringForStatus:call.status]);
        if(self.call == nil){
            self.call = call;
            [self showCallView:call];
        }
    }
}

-(void)showCallView:(RTCCall *)call {
    CallViewController *callViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callViewController.currentCall = call;
    callViewController.isIncoming = YES;
    [self presentViewController:callViewController animated:YES completion:nil];    
}

#pragma mark - IBAction

- (IBAction)logout:(id)sender {
    [self performSegueWithIdentifier:@"BackToLoginSegue" sender:self];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *contactCell = (ContactTableViewCell *)cell;
    Contact *contact = [self.allObjects objectAtIndex:indexPath.row];
    if(contact){
        contactCell.name.text = contact.fullName;
        NSArray<PhoneNumber *> *phoneNumbers = [NSArray arrayWithArray:[contact.phoneNumbers allObjects]];
        contactCell.phoneNumber.text = [phoneNumbers firstObject].number;
        if(contact.photoData){
            contactCell.avatar.image = [UIImage imageWithData: contact.photoData];
            contactCell.avatar.tintColor = [UIColor clearColor];
        } else {
            contactCell.avatar.image = [UIImage imageNamed:@"Default_Avatar"];
            contactCell.avatar.tintColor = [UIColor colorWithHue:(indexPath.row*36%100)/100.0 saturation:1.0 brightness:1.0 alpha:1.0];
        }
        contactCell.avatar.layer.cornerRadius = 30;
        contactCell.avatar.layer.masksToBounds = YES;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Contact *contact = [self.allObjects objectAtIndex:indexPath.row];
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"Calling :" message:contact.displayName preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *audioCall = [UIAlertAction actionWithTitle:@"Audio call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isVideoCall = NO;
        [self performSegueWithIdentifier:@"CallInProgressSegue" sender:self];
    }];
    UIAlertAction *videoCall = [UIAlertAction actionWithTitle:@"Video call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isVideoCall = YES;
        [self performSegueWithIdentifier:@"CallInProgressSegue" sender:self];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [menu addAction:audioCall];
    [menu addAction:videoCall];
    // MP call disabled
    //[menu addAction:mpCall];
    [menu addAction:cancel];
    [self presentViewController:menu animated:YES completion:nil];
}

@end
