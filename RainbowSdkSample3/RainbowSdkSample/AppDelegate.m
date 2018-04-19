/*
 * Rainbow SDK sample
 *
 * Copyright (c) 2016, ALE International
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
    [[ServicesManager sharedInstance].loginManager disconnect];
    [[ServicesManager sharedInstance].loginManager resetAllCredentials];
}

@end
