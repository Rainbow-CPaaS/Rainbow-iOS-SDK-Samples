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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[ServicesManager sharedInstance] setAppID:kAppID secretKey:kSecretKey];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // disconnect should not be called on the Main thread
    dispatch_async(dispatch_get_global_queue( QOS_CLASS_UTILITY, 0), ^{
        [[ServicesManager sharedInstance].loginManager disconnect];
    });
}

@end
