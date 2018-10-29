## Rainbow SDK Sample

### Setting the development environnement 
---
For informations about development environnement you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### Login to Rainbow server
---
For informations about the login process you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### WebRTC calls
---
The aim of this sample project is to demonstrate WebRTC phone calls. After the login screen your actual contacts that have provided a phone number are listed and you could try to make WebRTC calls to them.

#### Register for Notifications

```objective-c

// Register for Notifications

[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(didCallSuccess:) name:kTelephonyServiceDidAddCallNotification object:nil];
 
[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(didUpdateCall:) name:kTelephonyServiceDidUpdateCallNotification object:nil];

[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(didRemoveCall:) name:kTelephonyServiceDidRemoveCallNotification object:nil];
        
[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(statusChanged:) name:kRTCServiceCallStatsNotification object:nil];
        
[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(didAllowMicrophone:) name:kRTCServiceDidAllowMicrophoneNotification object:nil];
        
[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(didRefuseMicrophone:) name:kRTCServiceDidRefuseMicrophoneNotification object:nil];
        
```

#### Start Audio Call

```objective-c
RTCCall *currentVideoCall = [[ServicesManager sharedInstance].rtcService beginNewOutgoingCallWithPeer:_aContact withFeatures:(RTCCallFeatureAudio)];
```

 This will begin a new call with selected contact and notify **kTelephonyServiceDidAddCallNotification**

```objective-c
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

-(void)statsUpdated:(NSNotification *)notification {
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
```

#### Cancel Current Call

```objective-c
 [[ServicesManager sharedInstance].rtcService cancelOutgoingCall:currentCall];
 [[ServicesManager sharedInstance].rtcService hangupCall:currentCall];
```

#### Video Call
To start a video call you should pass the `RTCCallFeatureLocalVideo` feature like this,

```objective-c
RTCCall * currentCall = [[ServicesManager sharedInstance].rtcService beginNewOutgoingCallWithPeer:_aContact withFeatures:(RTCCallFeatureAudio|RTCCallFeatureLocalVideo)];
```

You may also add a video stream to a established audio call, first declare some properties and listen to video track notifications,

```objective-c
@property (strong, nonatomic) RTCCall *currentCall;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;
@property (nonatomic, weak) IBOutlet RTCCameraPreviewView *localVideoView;
@property (nonatomic, weak) IBOutlet RTCEAGLVideoView *remoteVideoView;
...
// Local video notifications
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddLocalVideoTrack:) name:kRTCServiceDidAddLocalVideoTrackNotification object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveLocalVideoTrack:) name:kRTCServiceDidRemoveLocalVideoTrackNotification object:nil];
// Remote video notifications
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddRemoteVideoTrack:) name:kRTCServiceDidAddRemoteVideoTrackNotification object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveRemoteVideoTrack:) name:kRTCServiceDidRemoveRemoteVideoTrackNotification object:nil];
```

When the local video stream is started the following notification is called,

```objective-c
-(void)didAddLocalVideoTrack:(NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didAddLocalVideoTrack:notification];
        });
        return;
    }
    
    RTCVideoTrack *localVideoTrack = (RTCVideoTrack *) notification.object;
    if(!localVideoTrack){
        RTCMediaStream *localStream = [[ServicesManager sharedInstance].rtcService localVideoStreamForCall:self.currentCall];
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
    self.localVideoView.captureSession = source.captureSession;
}
```
Then to add the video track to a established audio conversation you should do,

```objective-c
[[ServicesManager sharedInstance].rtcService addVideoMediaToCall:self.currentCall];
```

### RTC Call Status
The following status are supported for current call in `didUpdateCall:` if registered for `kTelephonyServiceDidUpdateCallNotification`,

| Presence constant | value | Meaning |
|------------------ | ----- | ------- |
| **`CallStatusRinging`** | 0 | Call is ringing |
| **`CallStatusConnecting`** | 1 | Call is accepted, we can proceed and establish |
| **`CallStatusDeclined`** | 2 | Call is declined |
| **`CallStatusTimeout`** | 3 | Call has not been accepted/decline in time. |
| **`CallStatusCanceled`** | 4 | Call has been canceled |
| **`CallStatusEstablished`** | 5 |  Call has been established |
| **`CallStatusHangup`** | 6 |  Call has been hangup |

```objective-c
-(void)didUpdateCall:(NSNotification *)notification {
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
```

