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

#import "CallViewController.h"
#import <WebRTC/WebRTC.h>


@interface RTCCameraPreviewView (PreviewLayer)
- (AVCaptureVideoPreviewLayer *)previewLayer;
@end

@interface CallViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;
@property (weak, nonatomic) IBOutlet UIButton *addVideoButton;

// Video
@property (nonatomic, weak) IBOutlet RTCCameraPreviewView *localVideoView;
@property (nonatomic, weak) IBOutlet RTCEAGLVideoView *remoteVideoView;

@property (strong, nonatomic) RTCService *rtcService;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;

@property (strong, nonatomic) RTCCameraVideoCapturer *cameraVideoCapturer;

@property (nonatomic) BOOL isCallEtablished;
@end

@implementation CallViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _localVideoTrack = nil;
        _remoteVideoTrack = nil;
        _isCallEtablished = NO;
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
    
    self.nameLabel.text = self.room.displayName;
    if(self.roomImage){
        self.avatar.image = self.roomImage;
    }
    self.avatar.layer.masksToBounds = YES;
    self.avatar.layer.cornerRadius = _avatar.frame.size.width/2.0;
    
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

-(void)showRemoteVideo {
    if([self.currentCall isRemoteVideoEnabled]){
        [self.remoteVideoTrack removeRenderer:self.remoteVideoView];
        self.remoteVideoTrack = nil;
        [self.remoteVideoView renderFrame:nil];
        
        RTCVideoTrack* videoTrack = [self.rtcService remoteVideoTrackForCall:self.currentCall];
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
                // Automatically answer incoming call
                [self.rtcService acceptIncomingCall:self.currentCall withFeatures:RTCCallFeatureAudio];
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
                    self.addVideoButton.enabled = YES;
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
#pragma mark - CaptureSession Settings

-(void)startCapturer {
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
    AVCaptureDevice *device = [self findDeviceForPosition:position];
    AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
    
    if (format == nil) {
        RTCLogError(@"No valid formats for device %@", device);
        NSAssert(NO, @"");
        
        return;
    }
    
    NSInteger fps = [self selectFpsForFormat:format];
    
    [self.cameraVideoCapturer startCaptureWithDevice:device format:format fps:fps];
}

- (AVCaptureDevice *)findDeviceForPosition:(AVCaptureDevicePosition)position {
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices[0];
}

- (NSInteger)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    Float64 maxFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxFramerate = fmax(maxFramerate, fpsRange.maxFrameRate);
    }
    return maxFramerate;
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
    NSArray<AVCaptureDeviceFormat *> *formats =
    [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    int targetWidth = 640;
    int targetHeight = 480;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        } else if (diff == currentDiff && pixelFormat == [_cameraVideoCapturer preferredOutputPixelFormat]) {
            selectedFormat = format;
        }
    }
    
    return selectedFormat;
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
    
    self.cameraVideoCapturer = (RTCCameraVideoCapturer *) notification.object;
    [self startCapturer];
}

-(void)didAddLocalVideoTrack:(NSNotification *) notification {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddLocalVideoTrack:notification];
        });
        return;
    }
    
    NSLog(@"didAddLocalVideoTrack notification");
    self.localVideoTrack = (RTCVideoTrack *) notification.object;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartCaptureSession:) name:AVCaptureSessionDidStartRunningNotification object:nil];
    self.localVideoView.captureSession = self.cameraVideoCapturer.captureSession;
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
