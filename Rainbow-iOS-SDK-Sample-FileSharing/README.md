## Rainbow SDK Sample

### Setting the development environnement 
---
For informations about development environnement you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### Login to Rainbow server
---
For informations about the login process you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### File sharing
---
The aim of this sample project is to demonstrate Rainbow file sharing on the cloud. After the login screen your actual contacts are listed.
You can select a contact to display more information about him and the files he share with you. 

### Retrieving the shared files by a contact

Once connected, you can get the list of shared files by your contact 

```objective-c 
    [self.fileSharingService loadSharedFilesWithPeer:self.contact fromOffset:0 completionHandler:^(NSArray<File *> *files, NSError *error) {
        if(error){
            NSLog(@"Error while loading shared files: %@", [error localizedDescription]);
        } else {
            self.sharedFiles = files;
        }
        ...
    }];
```
