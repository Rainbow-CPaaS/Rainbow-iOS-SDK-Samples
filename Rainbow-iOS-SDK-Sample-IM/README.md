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

##### Sending a file in attachment
Along the text message itself a file could be attached to a message and uploaded to the cloud.

Here follow a sample code that send a message with a UIImage as a attached jpeg file:  

```objective-c
File *attachmentFileToSend = nil;
UIImage *image = ...;
NSString *fileName = @"image.jpg";
NSData *dataToSend = UIImageJPEGRepresentation(image, 0.7);
NSURL *cacheURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
	[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject], fileName]];

attachmentFileToSend = [[ServicesManager sharedInstance].fileSharingService createTemporaryFileWithFileName:fileName andData:dataToSend andURL:cacheURL];

[[ServicesManager sharedInstance].conversationsManagerService sendMessage:@"Message to send" fileAttachment:attachmentFileToSend to:conversation completionHandler:^(Message *message, NSError *error) {
        // do something with **message**
        ...
        
        });
} attachmentUploadProgressHandler:^(Message *message, double totalBytesSent, double totalBytesExpectedToSend) {
        NSLog(@"total byte send  : %f",totalBytesSent);
        NSLog(@"total byte expected to send  : %f",totalBytesExpectedToSend);
      
}];
```

The recognized file types are the following:

```
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

##### Attachments
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

#### Last Message Correction

The Rainbow SDK since release 1.54.x support the IM message correction as described in 
[XEP-0308: Last Message Correction](https://xmpp.org/extensions/xep-0308.html). This provide the ability to the users to correct or suppress the last message sent to a IM conversation. The correction is done sending a new message with the corrected message or none for suppression, using:

```objective-c
/**
 *  replace the last recently sent message with a corrected one
 *
 *  @param message           message to replace
 *  @param text              new message text, if nil this would remove the last message
 *  @param conversation      conversation object in which you want to send the message
 *  @param completionHandler method to invoke when send action is completed
 *  @return message          return the message.
 */
-(Message *) sendReplacementMessageForMessage:(Message *)message replacementText:(NSString *)text to:(Conversation *) conversation completionHandler:(ConversationsManagerServiceSendMessageCompletionHandler) completionHandler;

```

After sending the correction message, the original message is not modified or suppressed, both messages are still sent when browsing the conversation, it is the responsability of the UI part of the application using the Rainbow SDK to deal with the correction/removing. 
The correction message has new attributes set to reference the corrected one:

```objective-c
/**
 * The message ID of the replaced message if this message is a replacement message
 * for a previously sent message in the XEP-0308 sense
 */
@property (nonatomic, readonly) NSString *replacedMessageID;

/**
 * The date of the replacement message if this one has been edited
 * See XEP-0308 for more details
 */
@property (nonatomic, readonly) NSDate *replacedDate;

```

