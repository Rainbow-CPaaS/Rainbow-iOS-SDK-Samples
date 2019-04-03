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
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation LoginViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _server = RAINBOW_SERVER;
    _doLogout = NO;
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
    self.loginButton.enabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:kLoginManagerDidLoginSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReconnect:) name:kLoginManagerDidReconnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedToAuthenticate:) name:kLoginManagerDidFailedToAuthenticate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:kLoginManagerDidLogoutSucceeded object:nil];
    
    if ([[ServicesManager sharedInstance].myUser username] &&[[ServicesManager sharedInstance].myUser password]) {
        [self.loginTextField setText:[[ServicesManager sharedInstance].myUser username];
        [self.passwordTextField setText:[[ServicesManager sharedInstance].myUser password]];
        [[ServicesManager sharedInstance].loginManager disconnect];
        [[ServicesManager sharedInstance].loginManager connect];
        self.loginButton.enabled = NO;
        [self.activityIndicatorView startAnimating];
         }
    if(self.doLogout){
        self.doLogout = NO;
        [self logoutAction:self];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginManagerDidLoginSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginManagerDidReconnect object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginManagerDidFailedToAuthenticate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginManagerDidLogoutSucceeded object:nil];
}

#pragma mark - Notifications

-(void) didLogin:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didLogin:notification];
        });
        return;
    }
    NSLog(@"[LoginViewController] Did login");
    self.loginButton.enabled = YES;
    [self.activityIndicatorView stopAnimating];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self performSegueWithIdentifier:@"DidLoginSegue" sender:self];
}

-(void) didReconnect:(NSNotification *) notification {
    NSLog(@"[LoginViewController] Did reconnect");
    [[ServicesManager sharedInstance].loginManager disconnect];
    [[ServicesManager sharedInstance].loginManager connect];
}

-(void)failedToAuthenticate:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self failedToAuthenticate:notification];
        });
        return;
    }
    NSLog(@"[LoginViewController] Failed to login");
    self.loginButton.enabled = YES;
    self.passwordTextField.text = @"";
    [self.activityIndicatorView stopAnimating];
    
}

-(void) didLogout:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didLogout:notification];
        });
        return;
    }
    NSLog(@"[LoginViewController] Did logout");
    [self.activityIndicatorView stopAnimating];
}

-(void)didChangeServer:(NSNotification *) notification {
    NSLog(@"[LoginViewController] Did changed server to : %@", (NSString *)notification.object);
}

#pragma mark - IBAction

- (IBAction)logoutAction:(id)sender {
    // disconnect should not be called on the Main thread
    dispatch_async(dispatch_get_global_queue( QOS_CLASS_UTILITY, 0), ^{
        [[ServicesManager sharedInstance].loginManager disconnect];
        [[ServicesManager sharedInstance].loginManager resetAllCredentials];
    });
}

- (IBAction)loginAction:(id)sender {
    NSString *login = self.loginTextField.text;
    NSString *passwd = self.passwordTextField.text;
    if([login length]>0 && [passwd length]>0){
        [[ServicesManager sharedInstance].loginManager setUsername:login andPassword:passwd];
        [[ServicesManager sharedInstance].loginManager connect];
        [self.activityIndicatorView startAnimating];
        self.loginButton.enabled = NO;

    }
}

@end
