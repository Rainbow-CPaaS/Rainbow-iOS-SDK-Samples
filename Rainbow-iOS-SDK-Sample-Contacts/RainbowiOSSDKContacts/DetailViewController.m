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

#import "DetailViewController.h"
#import <Rainbow/Rainbow.h>

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UITableView *infoList;

@property (strong, nonatomic) NSMutableArray<NSString *>* sectionHeaders;
@end

#define phoneNumbersStr @"Phone numbers"
#define eMailsStr @"eMails"

@implementation DetailViewController

-(void)updateUI {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
        });
        return;
    }
    self.nameLabel.text = self.contact.fullName;
    self.companyLabel.text = self.contact.companyName;
    if(self.contactImage){
        self.avatar.image = self.contactImage;
        if(self.contactImageTint){
            self.avatar.tintColor = self.contactImageTint;
        }
    }
    
    self.sectionHeaders = [[NSMutableArray alloc] init];
    if(self.contact.phoneNumbers && self.contact.phoneNumbers.count>0){
        [self.sectionHeaders addObject:phoneNumbersStr];
    }
    if(self.contact.emailAddresses && self.contact.emailAddresses.count>0){
        [self.sectionHeaders addObject:eMailsStr];
    }
    [self.infoList reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Update the UI with already fetched informations
    [self updateUI];
    
    // Fetch potentially missing informations about the contact
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetInfo:) name:kContactsManagerServiceDidUpdateContact object:nil];
    [[ServicesManager sharedInstance].contactsManagerService fetchRemoteContactDetail:self.contact];
}

#pragma mark - get contact info notification

-(void) didGetInfo:(NSNotification *) notification {
    self.contact = (Contact *)[notification.object objectForKey:@"contact"];
    [self updateUI];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionHeaders.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.sectionHeaders[section] isEqualToString:phoneNumbersStr]){
        return self.contact.phoneNumbers.count;
    } else if([self.sectionHeaders[section] isEqualToString:eMailsStr]){
        return self.contact.emailAddresses.count;
    } else {
        return 0;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionHeaders[section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView dequeueReusableCellWithIdentifier:@"DetailTableViewCell" forIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSString *label = @"";
    NSString *value = @"";
    if([self.sectionHeaders[section] isEqualToString:phoneNumbersStr]){
        NSArray<PhoneNumber *> *phoneNumbers = [NSArray arrayWithArray:[self.contact.phoneNumbers allObjects]];
        label = phoneNumbers[indexPath.row].label;
        value = phoneNumbers[indexPath.row].number;
    } else if([self.sectionHeaders[section] isEqualToString:eMailsStr]){
        label = self.contact.emailAddresses[indexPath.row].label;
        value = self.contact.emailAddresses[indexPath.row].address;
    } 
    cell.textLabel.text = label;
    cell.detailTextLabel.text = value;
}

@end
