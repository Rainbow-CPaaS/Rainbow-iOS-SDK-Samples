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
@property (nonatomic, weak) IBOutlet RTCCameraPreviewView *localVideoView;
@property (nonatomic, weak) IBOutlet RTCEAGLVideoView *remoteVideoView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *addVideoButton;

@property (strong, nonatomic) RTCService *rtcService;
@property (strong, nonatomic) RTCCall *currentCall;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;
@property (nonatomic) BOOL isCallEtablished;
@end

@implementation CallViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _currentCall = nil;
        _localVideoTrack = nil;
        _remoteVideoTrack = nil;
        _isCallEtablished = NO;
        _rtcService = [ServicesManager sharedInstance].rtcService;
        
        // Register for Notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCallSuccess:) name:kRTCServiceDidAddCallNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateCall:) name:kRTCServiceDidUpdateCallNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statsUpdated:) name:kRTCServiceCallStatsNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveCall:) name:kRTCServiceDidRemoveCallNotification object:nil];
        // Local video notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddLocalVideoTrack:) name:kRTCServiceDidAddLocalVideoTrackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveLocalVideoTrack:) name:kRTCServiceDidRemoveLocalVideoTrackNotification object:nil];
        // Remote video notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddRemoteVideoTrack:) name:kRTCServiceDidAddRemoteVideoTrackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveRemoteVideoTrack:) name:kRTCServiceDidRemoveRemoteVideoTrackNotification object:nil];
        // Microphone notifications
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidAddLocalVideoTrackNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidAddRemoteVideoTrackNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidRemoveLocalVideoTrackNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidRemoveRemoteVideoTrackNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidAllowMicrophoneNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidRefuseMicrophoneNotification object:nil];
    
    _currentCall = nil;
    _rtcService = nil;
    _localVideoTrack = nil;
    _remoteVideoTrack = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentCall = nil;
    _localVideoTrack = nil;
    _remoteVideoTrack = nil;
    
    self.nameLabel.text = self.contact.fullName;
    if(self.contactImage){
        self.avatar.image = self.contactImage;
        if(self.contactImageTint){
            self.avatar.tintColor = self.contactImageTint;
        }
    }
    [self.addVideoButton setTitle:@"Add video" forState:UIControlStateNormal];
    self.localVideoView.hidden = YES;
    self.remoteVideoView.hidden = YES;
    self.addVideoButton.enabled = NO;
    self.isCallEtablished = NO;
}

-(void) makeCallTo:(Contact *) contact features:(RTCCallFeatureFlags) features {
    if(self.rtcService.microphoneAccessGranted){
        self.currentCall = [self.rtcService beginNewOutgoingCallWithPeer:contact withFeatures:features];
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

-(void)showRemoteVideo {
    if([self.currentCall isRemoteVideoEnabled]){
        [self.remoteVideoTrack removeRenderer:self.remoteVideoView];
        self.remoteVideoTrack = nil;
        [self.remoteVideoView renderFrame:nil];
        RTCVideoTrack *videoTrack = [self.rtcService remoteVideoStreamForCall:self.currentCall].videoTracks[0];
        self.remoteVideoTrack = videoTrack;
        [self.remoteVideoTrack addRenderer:self.remoteVideoView];
        self.remoteVideoView.hidden = NO;
    }
}

#pragma mark - RTCCall notifications

-(void)didCallSuccess:(NSNotification *)notification {
    if([notification.object class] == [RTCCall class]){
        NSLog(@"didCallSuccess notification");
    }
}

-(void)didUpdateCall:(NSNotification *)notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didUpdateCall:notification];
        });
        return;
    }
    if([notification.object class] == [RTCCall class]){
        
        RTCCall *call = (RTCCall *) notification.object;
        switch (call.status) {
            case RTCCallStatusRinging: {
                NSLog(@"didUpdateCall notification: ringing");
                break;
            }
            case RTCCallStatusConnecting: {
                NSLog(@"didUpdateCall notification: connecting");
                break;
            }
            case RTCCallStatusDeclined: {
                NSLog(@"didUpdateCall notification: declined");
                break;
            }
            case RTCCallStatusTimeout: {
                NSLog(@"didUpdateCall notification: timeout");
                break;
            }
            case RTCCallStatusCanceled: {
                NSLog(@"didUpdateCall notification: canceled");
                break;
            }
            case RTCCallStatusEstablished: {
                NSLog(@"didUpdateCall notification: established");
                if(!self.isCallEtablished){
                    self.addVideoButton.enabled = YES;
                }
                self.isCallEtablished = YES;
                break;
            }
            case RTCCallStatusHangup: {
                NSLog(@"didUpdateCall notification: hangup");
                break;
            }
            default:
                NSLog(@"didUpdateCall notification: unknown state");
                break;
        }
    }
}

-(void)statsUpdated:(NSNotification *)notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self statsUpdated:notification];
        });
        return;
    }
    if([notification.object class] == [RTCCall class]){
        NSLog(@"statsUpdated notification");
        
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

#pragma mark - Local video call notifications

-(void)didAddLocalVideoTrack:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddLocalVideoTrack:notification];
        });
        return;
    }
    
    NSLog(@"didAddLocalVideoTrack notification");
    RTCVideoTrack *localVideoTrack = (RTCVideoTrack *) notification.object;
    if(!localVideoTrack){
        RTCMediaStream *localStream = [self.rtcService localVideoStreamForCall:self.currentCall];
        localVideoTrack = localStream.videoTracks[0];
    }
    if(self.localVideoTrack == localVideoTrack)
        return;
    
    self.localVideoTrack = nil;
    self.localVideoTrack = localVideoTrack;
    
    RTCAVFoundationVideoSource *source = nil;
    if ([localVideoTrack.source isKindOfClass:[RTCAVFoundationVideoSource class]]) {
        source = (RTCAVFoundationVideoSource*)localVideoTrack.source;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartCaptureSession:) name:AVCaptureSessionDidStartRunningNotification object:nil];
    self.localVideoView.captureSession = source.captureSession;
    
    self.localVideoView.hidden = NO;
    self.remoteVideoView.hidden = NO;
}

-(void) didRemoveLocalVideoTrack:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didRemoveLocalVideoTrack:notification];
        });
        return;
    }
    
    NSLog(@"didRemoveLocalVideoTrack notification");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:nil];
    self.localVideoTrack = nil;
    self.localVideoView.captureSession = nil;
    self.localVideoView.hidden = YES;
}

-(void) didStartCaptureSession:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self didStartCaptureSession:notification];
        });
        return;
    }
    
    NSLog(@"didStartCaptureSession notification");
}

#pragma mark - Remote video call notifications

-(void) didAddRemoteVideoTrack:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddRemoteVideoTrack:notification];
        });
        return;
    }
    
    NSLog(@"didAddRemoteVideoTrack notification");
    [self showRemoteVideo];
}

-(void) didRemoveRemoteVideoTrack:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didRemoveRemoteVideoTrack:notification];
        });
        return;
    }
    
    NSLog(@"didRemoveRemoteVideoTrack notification");
    if(![self.currentCall isRemoteVideoEnabled]){
        // We had a video and there is no more video, so remove it.
        self.remoteVideoView.hidden = YES;
        self.localVideoView.hidden = YES;
        return;
    }
}

#pragma mark - IBAction

- (IBAction)cancelCall:(id)sender {
    if(self.currentCall){
        [self.rtcService cancelOutgoingCall:self.currentCall];
        [self.rtcService hangupCall:self.currentCall];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)addVideo:(id)sender {
    if(self.currentCall){
        if(![self.currentCall isLocalVideoEnabled]){
            [self.addVideoButton setTitle:@"Stop video" forState:UIControlStateNormal];
            [self.rtcService addVideoMediaToCall:self.currentCall];
        } else {
            // once stopped, the video could not be started again
            self.addVideoButton.enabled = NO;
            [self.addVideoButton setTitle:@"Add video" forState:UIControlStateNormal];
            [self.rtcService removeVideoMediaFromCall:self.currentCall];
        }
    }
}

@end
