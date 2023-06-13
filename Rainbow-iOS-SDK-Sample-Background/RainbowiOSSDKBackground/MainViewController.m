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
#import "LoginViewController.h"
#import <Rainbow/Rainbow.h>
#import <Contacts/Contacts.h>
#import <Rainbow/ContactsManagerService.h>
#import <Rainbow/NotificationsManager.h>
#import "ContactTableViewCell.h"

@interface MainViewController ()
@property (nonatomic, strong) ServicesManager *serviceManager;
@property (nonatomic, strong) ContactsManagerService *contactsManager;
@property (nonatomic, strong) NSMutableArray<Contact *> *allObjects;
@property (nonatomic) BOOL populated;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
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
    
    [[ServicesManager sharedInstance].notificationsManager registerForUserNotificationsSettingsWithCompletionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(error){
            NSLog(@"[MainViewController] registerForUserNotificationsSettingsWithCompletionHandler returned a error: %@", [error localizedDescription]);
        } else if(granted){
            NSLog(@"[MainViewController] Push notifications granted");
        } else {
            NSLog(@"[MainViewController] Push notifications not granted");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPopulatingMyNetwork:) name:kContactsManagerServiceDidEndPopulatingMyNetwork object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddContact:) name:kContactsManagerServiceDidAddContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateContact:) name:kContactsManagerServiceDidUpdateContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveContact:) name:kContactsManagerServiceDidRemoveContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)applicationDidEnterBackground:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self applicationDidEnterBackground:notification];
        });
        return;
    }
    NSLog(@"[MainViewController] Application did enter background");
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
        if(index != NSNotFound) {
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
    for(Contact *contact in [ServicesManager sharedInstance].contactsManagerService.contacts) {
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
    if([_allObjects containsObject:contact]){
        [_allObjects removeObject:contact];
        
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
    
    if (contact.isInRoster){
        [self insertContact:contact];
    }
    else {
        if ([_allObjects containsObject:contact]) {
            [_allObjects removeObject:contact];
        }
    }
    if([self isViewLoaded] && _populated){
        [self.tableView reloadData];
    }
}

#pragma mark - Segue navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"BackToLoginSegue"]){
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
    Contact *contact = [self.allObjects objectAtIndex:indexPath.row];
    [self sendIM:[NSString stringWithFormat:@"Hello at %@", [NSDate date]] to:contact];
}

#pragma mark - Sending IM

-(void)sendIM:(NSString *)text to:(Contact *)contact {
    [[ServicesManager sharedInstance].conversationsManagerService startConversationWithPeer:contact withCompletionHandler:^(Conversation *conversation, NSError *error) {
        if(!error){
            [[ServicesManager sharedInstance].conversationsManagerService sendTextMessage:text files:nil mentions:nil priority:MessagePriorityDefault repliedMessage:nil conversation:conversation completionHandler:^(Message *message, NSError *error) {
                if(!error){
                    NSLog(@"[MainViewController] message '%@' sent to %@, XMPP message [ %@ ]",text , contact.displayName, message);
                    NSLog(@"[MainViewController] XMPP message [ %@ ]", [message debugDescription]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __block UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Message to %@",contact.displayName]  message:text preferredStyle:UIAlertControllerStyleAlert];
                        [self presentViewController:alert animated:YES completion:^{
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            });
                        }];
                    });
                } else {
                    NSLog(@"[MainViewController] Can't send message to the conversation error: %@",[error description]);
                }
            }];
        } else {
            NSLog(@"[MainViewController] Can't create the new conversation, error: %@", [error description]);
        }
    }];
}

@end
