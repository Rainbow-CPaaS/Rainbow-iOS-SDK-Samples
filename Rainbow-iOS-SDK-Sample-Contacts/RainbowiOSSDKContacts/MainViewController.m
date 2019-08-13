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
#import "DetailViewController.h"

@interface MainViewController ()
@property (nonatomic, strong) ServicesManager *serviceManager;
@property (nonatomic, strong) ContactsManagerService *contactsManager;
@property (nonatomic, strong) NSMutableArray<Contact *> *myContacts;
@property (nonatomic, strong) NSMutableArray<Invitation *> *invited;
@property (nonatomic) BOOL populated;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@end

@implementation MainViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _serviceManager = [ServicesManager sharedInstance];
        _contactsManager = _serviceManager.contactsManagerService;
        _myContacts = [[NSMutableArray alloc] init];
        _invited = [[NSMutableArray alloc] init];
        _populated = NO;
        _selectedIndex = nil;
    }
    return self;
}

-(void)dealloc {
    _myContacts = nil;
    _invited = nil;
    _serviceManager = nil;
    _contactsManager = nil;
    _selectedIndex = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPopulatingMyNetwork:) name:kContactsManagerServiceDidEndPopulatingMyNetwork object:nil];
    if(!_populated) {
        [self didEndPopulatingMyNetwork:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidEndPopulatingMyNetwork object:nil];
    if(_populated){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidAddContact object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidRemoveContact object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kContactsManagerServiceDidUpdateContact object:nil];
    }
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
    // Ignore temporary invited user
    if(contact.isInvitedUser) {
        return;
    }
    // Check if contact is in the roster
    if(!contact.isInRoster) {
        // Check if contact has been removed from my network
        if([_myContacts containsObject:contact]) {
            [_myContacts removeObject:contact];
        }
        return;
    } else {
        if (![_myContacts containsObject:contact]) {
            [_myContacts addObject:contact];
        } else {
            NSUInteger index =  [_myContacts indexOfObjectIdenticalTo:contact];
            if (index != NSNotFound) {
                [_myContacts replaceObjectAtIndex:index withObject:contact];
            }
        }
    }
    if(!contact.photoData){
        [self.contactsManager populateAvatarForContact:contact];
    }
}

-(void) updateInvitation:(Invitation *) invitation {
    Invitation *foundInvitation = nil;
    for(Invitation *invitation2 in _invited){
        if([invitation.invitationID isEqualToString:invitation2.invitationID]){
            foundInvitation = invitation2;
        }
    }

    if(invitation.status == InvitationStatusAccepted ||     // Invitation has been accepted
       invitation.status == InvitationStatusAutoAccepted || // Invitation has been auto-accepted due to users in same company
       
       invitation.status == InvitationStatusDeclined ||     // Invitation has been declined
       invitation.status == InvitationStatusDeleted ||      // Invitation has been deleted (by us on another device)
       invitation.status == InvitationStatusCanceled ||     // Invitation has been canceled (by owner of this invitation)
       invitation.status == InvitationStatusFailed) {       // Invitation has failed (bad eMail,...)
        
        if (foundInvitation != nil) {
            [_invited removeObject:foundInvitation];
        }
        
    } else {
        
        if (foundInvitation == nil) {
            [_invited addObject:invitation];
        } else {
            NSUInteger index =  [_invited indexOfObjectIdenticalTo:foundInvitation];
            if (index != NSNotFound) {
                [_invited replaceObjectAtIndex:index withObject:invitation];
            }
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
    
    // fill allObjects array with the contacts already loaded by the ContactsManager
    for(Contact *contact in _contactsManager.contacts){
        [self insertContact:contact];
    }
    
    // listen to update notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddContact:) name:kContactsManagerServiceDidAddContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveContact:) name:kContactsManagerServiceDidRemoveContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateContact:) name:kContactsManagerServiceDidUpdateContact object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddInvitation:) name:kContactsManagerServiceDidAddInvitation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateInvitation:) name:kContactsManagerServiceDidUpdateInvitation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveInvitation:) name:kContactsManagerServiceDidRemoveInvitation object:nil];
    
    // reload the contact list
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
    
    NSLog(@"[MainViewController] Did add contact");
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
    
    NSLog(@"[MainViewController] Did remove contact");
    Contact *contact = notification.object;
    if([self.myContacts containsObject:contact]){
        [self.myContacts removeObject:contact];
        
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
    
    NSLog(@"[MainViewController] Did update contact");
    NSDictionary *userInfo = (NSDictionary *)notification.object;
    Contact *contact = [userInfo objectForKey:kContactKey];
    
    [self insertContact:contact];
    if([self isViewLoaded] && _populated){
        [self.tableView reloadData];
    }
}

-(void) didAddInvitation:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddInvitation:notification];
        });
        return;
    }
    
    NSLog(@"[MainViewController] Did add invitation");
    Invitation *invitation = (Invitation *)notification.object;
    [self updateInvitation:invitation];
    if([self isViewLoaded] && _populated){
        [self.tableView reloadData];
    }
}

-(void) didUpdateInvitation:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didUpdateInvitation:notification];
        });
        return;
    }
    
    NSLog(@"[MainViewController] Did update invitation");
    Invitation *invitation = (Invitation *)notification.object;
    [self updateInvitation:invitation];
    if([self isViewLoaded] && _populated){
        [self.tableView reloadData];
    }
}

-(void) didRemoveInvitation:(NSNotification *) notification {
    // Enforce that this method is called on the main thread
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didRemoveInvitation:notification];
        });
        return;
    }
    
    NSLog(@"[MainViewController] Did remove invitation");
    Invitation *invitation = (Invitation *)notification.object;
    [self updateInvitation:invitation];
    if([self isViewLoaded] && _populated){
        [self.tableView reloadData];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(self.selectedIndex && [segue.identifier isEqualToString:@"ShowContactDetailSegue"]){
        DetailViewController *vc = segue.destinationViewController;
        vc.contact = [self.myContacts objectAtIndex:self.selectedIndex.row];
        vc.contactImage = ((ContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndex]).avatar.image;
        vc.contactImageTint = ((ContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndex]).avatar.tintColor;
    } else if ([segue.identifier isEqualToString: @"BackToLoginSegue"]){
        LoginViewController *loginViewController = (LoginViewController *)segue.destinationViewController;
        loginViewController.doLogout = YES;
    }
}

#pragma mark - IBAction

- (IBAction)logout:(id)sender {
    [self performSegueWithIdentifier:@"BackToLoginSegue" sender:self];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.myContacts.count > 0 ? 1 : 0) + (self.invited.count > 0 ? 1 : 0);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.invited.count > 0) {
        return self.invited.count;
    } else {
        return self.myContacts.count;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.invited.count > 0) {
        return @"Invited contacts";
    } else {
        return @"My network";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *contactCell = (ContactTableViewCell *)cell;
    if (indexPath.section == 0 && self.invited.count > 0) {
        Invitation *invitation = [self.invited objectAtIndex:indexPath.row];
        contactCell.name.text = invitation.email;
        contactCell.emailAddress.text = [NSString stringWithFormat:@"Sent on %@",[invitation.date description]];
        contactCell.avatar.image = [UIImage imageNamed:@"Default_Avatar"];
        contactCell.avatar.tintColor = [UIColor colorWithHue:((15+indexPath.row)*36%100)/100.0 saturation:1.0 brightness:1.0 alpha:1.0];
    } else {
        Contact *contact = [self.myContacts objectAtIndex:indexPath.row];
        contactCell.name.text = contact.fullName;
        if(contact.emailAddresses.count > 0){
            contactCell.emailAddress.text = [[contact.emailAddresses firstObject] address];
        }
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
    if (indexPath.section == 0 && self.invited.count > 0) {
        return;
    }
    [self performSegueWithIdentifier:@"ShowContactDetailSegue" sender:self];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.invited.count > 0) {
        Invitation *invitation = [self.invited objectAtIndex:indexPath.row];
        [self.contactsManager deleteInvitationWithID:invitation];
        return;
    }
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        Contact *contact = [self.myContacts objectAtIndex:indexPath.row];
        [self.contactsManager removeContactFromMyNetwork:contact];
    }
}

@end
