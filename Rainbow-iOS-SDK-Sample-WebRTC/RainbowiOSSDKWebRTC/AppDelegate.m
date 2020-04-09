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

#import "AppDelegate.h"
#import "Rainbow/Rainbow.h"

#define kAppID @"" 
#define kSecretKey @""

// Disable CallKit to be in the same conditions as where CallKit is forbidden like in China
//#define DISABLE_CALLKIT 1

@implementation AppDelegate

-(NSString *)applicationName {
    static NSString *_appName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        _appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if (!_appName) {
            _appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
        }
    });
    return _appName;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"disableCallKit":@NO }];
#ifdef DISABLE_CALLKIT
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"disableCallKit"];
#endif
    [[ServicesManager sharedInstance] setAppID:kAppID secretKey:kSecretKey];
    [[ServicesManager sharedInstance].rtcService requestMicrophoneAccess];
    [[ServicesManager sharedInstance].rtcService startCallKitWithIncomingSoundName:@"incoming-call.mp3" iconTemplate:@"logo" appName:[self applicationName]];
    [ServicesManager sharedInstance].rtcService.appSoundOutgoingCall = @"outgoing-rings.mp3";
    [ServicesManager sharedInstance].rtcService.appSoundHangup = @"hangup.wav";

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
