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

[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(didCallSuccess:) name:kRTCServiceDidAddCallNotification object:nil];
 
[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(didUpdateCall:) name:kRTCServiceDidUpdateCallNotification object:nil];
        
[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(statusChanged:) name:kRTCServiceCallStatsNotification object:nil];
        
[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(didRemoveCall:) name:kRTCServiceDidRemoveCallNotification object:nil];
        
[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(didAllowMicrophone:) name:kRTCServiceDidAllowMicrophoneNotification object:nil];
        
[[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(didRefuseMicrophone:) name:kRTCServiceDidRefuseMicrophoneNotification object:nil];
        
```

#### Start Audio Call

```objective-c
RTCCall *currentVideoCall = [[ServicesManager sharedInstance].rtcService beginNewOutgoingCallWithContact:_aContact withFeatures:(RTCCallFeatureAudio)];
```

 This will begin a new call with selected contact and notify **kRTCServiceDidAddCallNotification**

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
```

#### Cancel Current Call

```objective-c
 [[ServicesManager sharedInstance].rtcService cancelOutgoingCall:currentCall];
 [[ServicesManager sharedInstance].rtcService hangupCall:currentCall];
```

### RTC Call Status
The following Status are supported for current call,

| Presence constant | value | Meaning |
|------------------ | ----- | ------- |
| **`RTCCallStatusRinging`** | 0 | Call is ringing |
| **`RTCCallStatusConnecting`** | 1 | Call is accepted, we can proceed and establish |
| **`RTCCallStatusDeclined`** | 2 | Call is declined |
| **`RTCCallStatusTimeout`** | 3 | Call has not been accepted/decline in time. |
| **`RTCCallStatusCanceled`** | 4 | Call has been canceled |
| **`RTCCallStatusEstablished`** | 5 |  Call has been established |
| **`RTCCallStatusHangup`** | 6 |  Call has been hangup |

