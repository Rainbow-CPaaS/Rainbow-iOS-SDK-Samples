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

#import "LoginViewController.h"
#import <Rainbow/Rainbow.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *serverLabel;
@end

@implementation LoginViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _server = RAINBOW_SERVER;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serverLabel.text = self.server;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeServer:) name:kLoginManagerDidChangeServer object:nil];
    
    if(self.server){
        [[NSNotificationCenter defaultCenter] postNotificationName:kChangeServerURLNotification object:@{ @"serverURL": self.server}];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSString *login = self.loginTextField.text;
    NSString *passwd = self.passwordTextField.text;
    if([login length]>0 && [passwd length]>0){
        return YES;
    } else {
        return NO;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[ServicesManager sharedInstance].loginManager setUsername:self.loginTextField.text andPassword:self.passwordTextField.text];
    [[ServicesManager sharedInstance].loginManager connect];
}

-(void)didChangeServer:(NSNotification *) notification {
    NSLog(@"Did changed server to : %@", (NSString *)notification.object);
}
@end
