## Rainbow SDK Sample

### Setting the development environnement 
---
For informations about development environnement you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### Login to Rainbow server
---
For informations about the login process you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### Push notifications handling
---
The aim of this sample project is to demonstrate the handling of push notifications.

#### Register for notifications

```objective-c

// Register for Notifications

...
    [[ServicesManager sharedInstance].notificationsManager registerForUserNotificationsSettingsWithCompletionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(error){
            NSLog(@"registerForUserNotificationsSettingsWithCompletionHandler returned a error: %@", [error localizedDescription]);
        } else if(granted){
            NSLog(@"Push notifications granted");
        } else {
            NSLog(@"Push notifications not granted");
        }
    }];
...
```

```objective-c
-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    [[ServicesManager sharedInstance].notificationsManager didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"User refuse to enable push notification");
}
```

#### Receiving push notifications

```objective-c
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *) userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"The application received a push notification");
    [[ServicesManager sharedInstance].notificationsManager didReceiveNotificationWithUserInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}
```
