## Rainbow SDK Sample

### Setting the development environnement 
---
For informations about development environnement you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### Login to Rainbow server
---
For informations about the login process you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### Instant Messaging
---
The aim of this sample project is to demonstrate the Instant Messaging API. After the login screen your actual contacts are listed and you could start IM messaging with them.

#### Retrieve Conversations
Retrieving all messages done as follow,

```objective-c
 NSArray<Conversation *> *conversationsArray = [ServicesManager sharedInstance].conversationsManagerService.conversations;
```
This will give you a list of all your conversations.

If you want to listen to changes in any conversations, you can use this `kConversationsManagerDidUpdateConversation` notification as follow,

```objective-c
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateConversation:) name:kConversationsManagerDidUpdateConversation object:nil];
```

```objective-c
 Conversation * updatedConversation = (Conversation *)notification.object;
 // do some thing with this updatedConversation ...
 ...
```


#### Listen to incoming messages and answer to them

##### Listen to incoming messages

Listening to instant messages that come from other users is very easy. You just have to use the  `kConversationsManagerDidReceiveNewMessageForConversation` event:

```objective-c
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMessage:) name:kConversationsManagerDidReceiveNewMessageForConversation object:nil];
```
 

```objective-c
 - (void) didReceiveNewMessage : (NSNotification *) notification {
   
    Conversation * receivedConversation  = notification.object;
    //do something with **recivedConversation** object
    
 }
```

##### Sending a new message
You can send a new message to contact as follow ,

```objective-c
 [[ServicesManager sharedInstance].conversationsManagerService sendMessage:@"Message to send" fileAttachment:nil to:conversation completionHandler:^(Message *message, NSError *error) {
        // do something with **message**
        ...
        
        });
    } attachmentUploadProgressHandler:^(Message *message, double totalBytesSent, double totalBytesExpectedToSend) {
        NSLog(@"total byte send  : %f",totalBytesSent);
        NSLog(@"total byte expected to send  : %f",totalBytesExpectedToSend);
      
    }];
```


#### Manually send a 'read' receipt

If you want to mark all messages as read for a conversation you can use `markAsReadByMeAllMessageForConversation` method, as follow,

```objective-c
  [[ServicesManager sharedInstance].conversationsManagerService markAsReadByMeAllMessageForConversation:conversation];

```

#### Listen to receipts

Receipts allow to know if the message has been successfully delivered to your recipient, following are the list of status for each message,

| message State | value | Meaning |
|------------------ | ----- | ------- |
| **`MessageDeliveryStateSent`** | 0 | The message state is **send** to server |
| **`MessageDeliveryStateDelivered`** | 1 | The message state is **Delevered**  |
| **`MessageDeliveryStateReceived`** | 2 | The message state is **Received**  |
| **`MessageDeliveryStateRead`** | 3 | The message state is **Read** |
| **`MessageDeliveryStateFailed`** | 4 | The message state is **Failed** to send |

You Can check paramerter **state** for each message as follow,

```objective-c
Message *message = // message to check state
NSLog(@"%ld",(long)message.state);
```
#### Get Conversation History

You can get history for a conversation, as follow,

```objective-c
// pageSize The maximum number of retrieved for example 20.
// preload retreive imediately from the local cache 

MessagesBrowser *messagesBrowser = [[ServicesManager sharedInstance].conversationsManagerService messagesBrowserForConversation:currentConversation withPageSize:20 preloadMessages:YES];
                        
messagesBrowser.delegate = self;         
```

```objective-c
#pragma mark - CKItemsBrowserDelegate

-(void) itemsBrowser:(CKItemsBrowser*)browser didAddCacheItems:(NSArray*)newItems atIndexes:(NSIndexSet*)indexes {

    dispatch_async(dispatch_get_main_queue(), ^{
        [messagesArray insertObjects:newItems atIndexes:indexes];
        [self.tableView reloadData];
    }); 
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didRemoveCacheItems:(NSArray*)removedItems atIndexes:(NSIndexSet*)indexes{
    NSLog(@"Removed!");
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didUpdateCacheItems:(NSArray*)changedItems atIndexes:(NSIndexSet*)indexes {
    dispatch_async(dispatch_get_main_queue(), ^{
        [messagesArray replaceObjectsAtIndexes:indexes withObjects:changedItems];
        [self.tableView reloadData];
    });
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didReorderCacheItemsAtIndexes:(NSArray*)oldIndexes toIndexes:(NSArray*)newIndexes {
    NSLog(@"Reorderd!");
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didReceiveItemsAddedEvent:(NSArray*)addedItems{
    
     NSLog(@"ReceivedItemsAdded!");
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didReceiveItemsDeletedEvent:(NSArray*)deletedItems{
    
     NSLog(@"ReceivedItemsDeleted!");
}

-(void) itemsBrowserDidReceivedAllItemsDeletedEvent:(CKItemsBrowser*)browser{
    
     NSLog(@"ReceivedAllItemsDeleted!");
}
```

#### Dealing with attachments
Optionally a file like a image, a video,... could be attached to messages. The file is uploaded in the cloud and a preview image is computed on the server if it is relevant.
The thumbnail image might be retrieved like this,

```objective-c
if(message.attachment && message.attachment.thumbnailData){
     UIImage image = [UIImage imageWithData:message.attachment.thumbnailData];
}
```

The file itself may or may not be cached locally, if it is not already downloaded from the cloud, this could be done like this,

```objective-c
	File *file = message.attachment;
	if(!file.data){
        [[ServicesManager sharedInstance].fileSharingService downloadDataForFile:file withCompletionHandler:^(File *aFile, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!error){
                ...
                } else {
                ...
                }
            }
        }];
    }       
```

The file type could be checked using `file.type` with value in 

```objective-c
typedef NS_ENUM(NSInteger, FileType) {
    FileTypeImage,
    FileTypePDF,
    FileTypeDoc,
    FileTypePPT,
    FileTypeXLS,
    FileTypeAudio,
    FileTypeVideo,
    FileTypeOther
};
```


