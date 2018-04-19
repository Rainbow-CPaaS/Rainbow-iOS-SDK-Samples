//
//  CallViewController.m
//  RainbowSdkSample2
//
//  Created by Vladimir Vyskocil on 11/04/2018.
//  Copyright © 2018 ALE. All rights reserved.
//

#import "CallViewController.h"

@interface CallViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) IBOutlet RTCCall *currentCall;
@end

@implementation CallViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _currentCall = nil;
        
        // Register for Notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCallSuccess:) name:kRTCServiceDidAddCallNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateCall:) name:kRTCServiceDidUpdateCallNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusChanged:) name:kRTCServiceCallStatsNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveCall:) name:kRTCServiceDidRemoveCallNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAllowMicrophone:) name:kRTCServiceDidAllowMicrophoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefuseMicrophone:) name:kRTCServiceDidRefuseMicrophoneNotification object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidAddCallNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidUpdateCallNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceCallStatsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidRemoveCallNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidAllowMicrophoneNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidRefuseMicrophoneNotification object:nil];
    
    _currentCall = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentCall = nil;
    
    self.nameLabel.text = self.contact.fullName;
    if(self.contactImage){
        self.avatar.image = self.contactImage;
        if(self.contactImageTint){
            self.avatar.tintColor = self.contactImageTint;
        }
    }
}

-(void) makeCallTo:(Contact *) contact features:(RTCCallFeatureFlags) features {
    if([ServicesManager sharedInstance].rtcService.microphoneAccessGranted){
        self.currentCall = [[ServicesManager sharedInstance].rtcService beginNewOutgoingCallWithPeer:contact withFeatures:features];
        if(!self.currentCall){
            NSLog(@"Error making WebRTC call");
        }
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Access to microphone" message:@"Without your auhtorisation to use microphone, the callee will not be able to hear you during call." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Go to Settings" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                               }];
        [alert addAction:settingsAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


-(void)viewDidAppear:(BOOL)animated {
    [self makeCallTo:self.contact features:RTCCallFeatureAudio];
}

#pragma mark - RTCCall notifications

-(void)didCallSuccess:(NSNotification *)notification {
    if([notification.object class] == [RTCCall class]){
        NSLog(@"didCallSuccess notification");
    }
}

-(void)didUpdateCall:(NSNotification *)notification {
    if([notification.object class] == [RTCCall class]){
        NSLog(@"didUpdateCall notification");
    }
}

-(void)statusChanged:(NSNotification *)notification {
    if([notification.object class] == [RTCCall class]){
        NSLog(@"statusChanged notification");
    }
}

-(void)didRemoveCall:(NSNotification *)notification {
    if([notification.object class] == [RTCCall class]){
        NSLog(@"didRemoveCall notification");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)didAllowMicrophone:(NSNotification *)notification {
    if([notification.object class] == [RTCCall class]){
       NSLog(@"didAllowMicrophone notification");
    }
}

-(void)didRefuseMicrophone:(NSNotification *)notification {
    if([notification.object class] == [RTCCall class]){
        NSLog(@"didRefuseMicrophone notification");
    }
}

#pragma mark - IBAction

- (IBAction)cancelCall:(id)sender {
    if(self.currentCall){
        [[ServicesManager sharedInstance].rtcService cancelOutgoingCall:self.currentCall];
        [[ServicesManager sharedInstance].rtcService hangupCall:self.currentCall];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
