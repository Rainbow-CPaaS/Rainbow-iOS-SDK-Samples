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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPopulatingMyNetwork:) name:kContactsManagerServiceDidEndPopulatingMyNetwork object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddContact:) name:kContactsManagerServiceDidAddContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateContact:) name:kContactsManagerServiceDidUpdateContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveContact:) name:kContactsManagerServiceDidRemoveContact object:nil];
    // RTC call notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddCall:) name:kTelephonyServiceDidAddCallNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidAddContact object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidUpdateContact object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidRemoveContact object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidEndPopulatingMyNetwork object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTelephonyServiceDidAddCallNotification object:nil];
}

-(void) insertContact:(Contact *) contact {
    // Ignore myself
    if (contact == _serviceManager.myUser.contact) {
        return;
    }
    // Ignore bots
    if(contact.isBot) {
        return;
    }
    // Ignore contact not in the roster
    if(!contact.isInRoster){
        return;
    }
    
    if (![_allObjects containsObject:contact]) {
        [_allObjects addObject:contact];
    } else {
        NSUInteger index =  [_allObjects indexOfObjectIdenticalTo:contact];
        [_allObjects replaceObjectAtIndex:index withObject:contact];
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
    
    if(contact){
        [self insertContact:contact];
        
        if([self isViewLoaded] && _populated){
            [self.tableView reloadData];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"CallInProgressSegue"]){
        CallViewController *vc = segue.destinationViewController;
        if(self.selectedIndex){
            vc.contact = [self.allObjects objectAtIndex:self.selectedIndex.row];
            vc.contactImage = ((ContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndex]).avatar.image;
            vc.contactImageTint = ((ContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndex]).avatar.tintColor;
            vc.isIncoming = NO;
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

-(void)didAddCall:(NSNotification *)notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddCall:notification];
        });
        return;
    }
    
    if([notification.object class] == [RTCCall class]){
        NSLog(@"didAddCall notification");
        self.call = (RTCCall *) notification.object;
        [self performSegueWithIdentifier:@"CallInProgressSegue" sender:self];
    }
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
        contactCell.phoneNumber.text = [contact.phoneNumbers firstObject].number;
        if(contact.photoData){
            contactCell.avatar.image = [UIImage imageWithData: contact.photoData];
            contactCell.avatar.tintColor = [UIColor clearColor];
        } else {
            contactCell.avatar.image = [UIImage imageNamed:@"Default_Avatar"];
            contactCell.avatar.tintColor = [UIColor colorWithHue:(indexPath.row*36%100)/100.0 saturation:1.0 brightness:1.0 alpha:1.0];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"CallInProgressSegue" sender:self];
}

@end
