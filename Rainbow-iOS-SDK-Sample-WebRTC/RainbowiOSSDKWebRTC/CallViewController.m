//
//  CallViewController.m
//  RainbowiOSSDKWebRTC
//
//  Created by Vladimir Vyskocil on 11/04/2018.
//  Copyright © 2018 ALE. All rights reserved.
//

#import "CallViewController.h"
#import <WebRTC/WebRTC.h>


@interface RTCCameraPreviewView (PreviewLayer)
- (AVCaptureVideoPreviewLayer *)previewLayer;
@end

@interface CallViewController ()
@property (weak, nonatomic) IBOutlet UILabel *callProgress;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *addVideoButton;

// Video
@property (nonatomic, weak) IBOutlet RTCCameraPreviewView *localVideoView;
@property (nonatomic, weak) IBOutlet RTCEAGLVideoView *remoteVideoView;

@property (strong, nonatomic) RTCService *rtcService;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;

@property (strong, nonatomic) AVCaptureSession *cameraCaptureSession;

@property (nonatomic) BOOL isCallEtablished;
@end

@implementation CallViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _localVideoTrack = nil;
        _remoteVideoTrack = nil;
        _isCallEtablished = NO;
        _isIncoming = NO;
        _rtcService = [ServicesManager sharedInstance].rtcService;
        
        // Register for TelephonyService notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCallSuccess:) name:kTelephonyServiceDidAddCall object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateCall:) name:kTelephonyServiceDidUpdateCall object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveCall:) name:kTelephonyServiceDidRemoveCall object:nil];
        // Register for stats notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statsUpdated:) name:kRTCServiceCallStats object:nil];
        // Local video notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddCaptureSession:) name:kRTCServiceDidAddCaptureSession object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddLocalVideoTrack:) name:kRTCServiceDidAddLocalVideoTrack object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveLocalVideoTrack:) name:kRTCServiceDidRemoveLocalVideoTrack object:nil];
        // Remote video notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddRemoteVideoTrack:) name:kRTCServiceDidAddRemoteVideoTrack object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveRemoteVideoTrack:) name:kRTCServiceDidRemoveRemoteVideoTrack object:nil];
        // Microphone notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAllowMicrophone:) name:kRTCServiceDidAllowMicrophone object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefuseMicrophone:) name:kRTCServiceDidRefuseMicrophone object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTelephonyServiceDidAddCall object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTelephonyServiceDidUpdateCall object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTelephonyServiceDidRemoveCall object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceCallStats object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidAddCaptureSession object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidAddLocalVideoTrack object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidAddRemoteVideoTrack object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidRemoveLocalVideoTrack object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidRemoveRemoteVideoTrack object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidAllowMicrophone object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRTCServiceDidRefuseMicrophone object:nil];
    
    _currentCall = nil;
    _rtcService = nil;
    _localVideoTrack = nil;
    _remoteVideoTrack = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _localVideoTrack = nil;
    _remoteVideoTrack = nil;
    
    self.nameLabel.text = self.contact.fullName;
    if(self.contactImage){
        self.avatar.image = self.contactImage;
        self.avatar.layer.cornerRadius = 60;
        self.avatar.layer.masksToBounds = YES;
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

-(BOOL) checkMicrophoneAccess {
    if(self.rtcService.microphoneAccessGranted){
        return YES;
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Access to microphone" message:@"Without your auhtorisation to use microphone, the callee will not be able to hear you during call." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Go to Settings" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                                                               }];
        [alert addAction:settingsAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    return NO;
}

-(void) makeCallTo:(RainbowContact *) contact features:(RTCCallFeatureFlags) features {
    if([self checkMicrophoneAccess]){
        self.currentCall = [self.rtcService beginNewOutgoingCallWithPeer:contact withFeatures:features andSubject:@"RainbowiOSSDKWebRTC calling !" ];
        if(!self.currentCall){
            NSLog(@"Error making WebRTC call");
        }
    }
    
}

-(void)setPeerAvatar:(RainbowContact *)peer {
    self.contact = peer;
    if (self.contact.photoData){
        self.contactImage = [UIImage imageWithData: self.contact.photoData];
    }
    self.nameLabel.text = self.contact.fullName;
    if(self.contactImage){
        self.avatar.image = self.contactImage;
        self.avatar.layer.cornerRadius = 60;
        self.avatar.layer.masksToBounds = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.isIncoming){
        NSLog(@"Incoming call !");
        self.callProgress.text = @"In call with";
        if(self.currentCall.peer.class == RainbowContact.class){
            [self setPeerAvatar:(RainbowContact *)self.currentCall.peer];
        }
        [self.cancelButton setTitle:@"Take call" forState:UIControlStateNormal];
    } else {
        self.callProgress.text = @"Calling...";
        if (self.isVideoCall) {
            [self makeCallTo:self.contact features:(RTCCallFeatureAudio | RTCCallFeatureLocalVideo)];
        } else {
            [self makeCallTo:self.contact features:(RTCCallFeatureAudio)];
        }
    }
}

-(void)showRemoteVideo {
    if([self.currentCall isRemoteVideoEnabled]){
        [self.remoteVideoTrack removeRenderer:self.remoteVideoView];
        self.remoteVideoTrack = nil;
        [self.remoteVideoView renderFrame:nil];
        RTCVideoTrack *videoTrack = [self.rtcService remoteVideoTrackForCall:self.currentCall];
        self.remoteVideoTrack = videoTrack;
        [self.remoteVideoTrack addRenderer:self.remoteVideoView];
        self.remoteVideoView.hidden = NO;
        [self.view setNeedsLayout];
    }
}

-(void) removeLocalVideoTrack {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:nil];
    self.localVideoTrack = nil;
    self.localVideoView.captureSession = nil;
    self.localVideoView.hidden = YES;
}

#pragma mark - RTCCall notifications

-(void)didCallSuccess:(NSNotification *)notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didCallSuccess:notification];
        });
        return;
    }
    
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
            case CallStatusRinging: {
                NSLog(@"didUpdateCall notification: ringing");
                break;
            }
            case CallStatusConnecting: {
                NSLog(@"didUpdateCall notification: connecting");
                break;
            }
            case CallStatusDeclined: {
                NSLog(@"didUpdateCall notification: declined");
                break;
            }
            case CallStatusTimeout: {
                NSLog(@"didUpdateCall notification: timeout");
                break;
            }
            case CallStatusCanceled: {
                NSLog(@"didUpdateCall notification: canceled");
                break;
            }
            case CallStatusEstablished: {
                NSLog(@"didUpdateCall notification: established");
                if(!self.isCallEtablished){
                    self.callProgress.text = @"In call with";
                    self.addVideoButton.enabled = YES;
                    [self.cancelButton setTitle:@"Hangup" forState:UIControlStateNormal];
                }
                self.isCallEtablished = YES;
                break;
            }
            case CallStatusHangup: {
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
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didRemoveCall:notification];
        });
        return;
    }
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

-(void) rotateLocalVideoView {
    AVCaptureConnection *previewLayerConnection=self.localVideoView.previewLayer.connection;
    if ([previewLayerConnection isVideoOrientationSupported]){
        AVCaptureVideoOrientation videoOrientation;
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            default:
            case UIInterfaceOrientationPortrait:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
        }
        
        [previewLayerConnection setVideoOrientation:videoOrientation];
    }
}

-(void)didAddCaptureSession:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddCaptureSession:notification];
        });
        return;
    }
    
    self.cameraCaptureSession = (AVCaptureSession *) notification.object;
}

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
        localVideoTrack = [self.rtcService localVideoTrackForCall:self.currentCall];
    }
    if(self.localVideoTrack == localVideoTrack)
        return;
    
    self.localVideoTrack = nil;
    self.localVideoTrack = localVideoTrack;
    
    RTCVideoSource *source = nil;
    if ([localVideoTrack.source isKindOfClass:[RTCVideoSource class]]) {
        source = (RTCVideoSource*)localVideoTrack.source;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartCaptureSession:) name:AVCaptureSessionDidStartRunningNotification object:nil];
    self.localVideoView.captureSession = self.cameraCaptureSession;
    self.localVideoView.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.addVideoButton setTitle:@"Stop video" forState:UIControlStateNormal];
    self.localVideoView.hidden = NO;
}

-(void) didRemoveLocalVideoTrack:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didRemoveLocalVideoTrack:notification];
        });
        return;
    }
    
    NSLog(@"didRemoveLocalVideoTrack notification");
    [self removeLocalVideoTrack];
}

-(void) didStartCaptureSession:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self didStartCaptureSession:notification];
        });
        return;
    }
    
    NSLog(@"didStartCaptureSession notification");
    [self rotateLocalVideoView];
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
    if(self.isIncoming && self.currentCall && self.currentCall.status == CallStatusRinging){
        [self.rtcService acceptIncomingCall:self.currentCall withFeatures:RTCCallFeatureAudio];
    } else {
        if(self.currentCall){
            [self.rtcService cancelOutgoingCall:self.currentCall];
            [self.rtcService hangupCall:self.currentCall];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
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
