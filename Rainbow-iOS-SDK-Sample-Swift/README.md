## Rainbow SDK Sample

### Setting the development environnement 
---
For informations about development environnement you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### The Sample
---
The aim of this sample project is to demonstrate the usage of the Swift language with iOS Rainbow SDK.

### Conversations and Instant Messaging
---
The first part of the sample  demonstrates the Conversation managements and Instant Messaging API. 

#### Retrieve Conversations
Retrieving all conversations done as follow,

```swift
func loadAllConversations() {
for conversation in conversationsManager.conversations {

// add conversation to conversations list

if(conversation.peer != nil) {
allConversations.append(conversation)
}
}
}
```
This will give you a list of all your conversations.

If you want to listen to changes in any conversations, you can use this `kConversationsManagerDidUpdateConversation` notification as follow,

```swift
NotificationCenter.default.addObserver(self, selector: #selector(didUpdateConversation(notification:)), name:NSNotification.Name(kConversationsManagerDidUpdateConversation), object: nil)
```

#### Listen to incoming messages and answer to them

##### Listen to incoming messages

Listening to instant messages that come from other users is very easy. You just have to use the  `kConversationsManagerDidReceiveNewMessageForConversation` event:

```swift
NotificationCenter.default.addObserver(self, selector:#selector(didReceiveNewMessageForConversation(notification:)), name:NSNotification.Name(kConversationsManagerDidReceiveNewMessageForConversation), object:nil)
```


```swift
@objc func didReceiveNewMessageForConversation(notification : Notification) {
...
// do something when recieved new message in conversation
if let receivedConversation = notification.object as? Conversation {
if(receivedConversation == self.theConversation){
...
reload messages list and mark recieved message status as read
...
}
}
}
```

##### Sending a new message
You can send a new message to contact as follow ,

```swift
conversationsManager.sendMessage("Message to send", fileAttachment:nil, to:theConversation, completionHandler: {
(message:Optional<Message>, error:Optional<Error>) in
DispatchQueue.main.async {
// do something with **message**
}
...
});
```
#### Get Conversation History

You can get history for a conversation, as follow,

```swift
// pageSize The maximum number of retrieved for example 50.
// preload retreive imediately from the local cache 

messagesBrowser = conversationsManager.messagesBrowser(for: self.theConversation, withPageSize:kPageSize, preloadMessages:true)
messagesBrowser?.delegate = self

```

```swift
// MARK: - CKItemsBrowserDelegate

func itemsBrowser(_ browser: CKItemsBrowser!, didAddCacheItems newItems: [Any]!, at indexes: IndexSet!) {
NSLog("CKItemsBrowser didAddCacheItems")
synchronized(self.messages as AnyObject) {
for (index, _) in indexes.sorted().enumerated() {
...
// insert new items at the beginning of the messages array
//sort received messages according to the last update date
...
}
}
}

func itemsBrowser(_ browser: CKItemsBrowser!, didRemoveCacheItems removedItems: [Any]!, at indexes: IndexSet!) {
NSLog("CKItemsBrowser didRemoveCacheItems")
}

func itemsBrowser(_ browser: CKItemsBrowser!, didUpdateCacheItems changedItems: [Any]!, at indexes: IndexSet!) {
NSLog("CKItemsBrowser didUpdateCacheItems")
}

func itemsBrowser(_ browser: CKItemsBrowser!, didReorderCacheItemsAtIndexes oldIndexes: [Any]!, toIndexes newIndexes: [Any]!) {
NSLog("CKItemsBrowser didReorderCacheItemsAtIndexes")
}
}
```
### Contact management
---
Second part of the sample  demonstrates Rainbow contact's management. We display list of contacts that are in user's network, also you can select a contact to display more information about him like the company he belongs, his phone numbers,...

### Retrieve the list of contacts

Once connected, you can get the list of your contact when the `ContactsManagerService` has finished to retrieve the contacts from the server and has sent the `kContactsManagerServiceDidEndPopulatingMyNetwork` notifications and populated the `contactsManager.myNetworkContacts` array,

```swift 
    override func viewWillAppear(_ animated: Bool) {
    ...
    NotificationCenter.default.addObserver(self, selector: #selector(didEndPopulatingMyNetwork), name: NSNotification.Name(kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
    ...
  }

    @objc func didEndPopulatingMyNetwork() {
    ...
    // fill contacts in user network using insert method
    for contact in contactsManager.myNetworkContacts {
    self.insert(contact)    
    }
    ...   
 }

// listen to further update notifications
    NotificationCenter.default.addObserver(self,selector:#selector(didAddContact(notification:)), name: NSNotification.Name(kContactsManagerServiceDidAddContact), object: nil)
    NotificationCenter.default.addObserver(self,selector:#selector(didUpdateContact(notification:)),name: NSNotification.Name(kContactsManagerServiceDidUpdateContact), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didRemoveContact(notification:)), name:
    NSNotification.Name(kContactsManagerServiceDidRemoveContact), object: nil)}
    ```

Then you should listen to the contact update notifications and take actions accordingly,

```swift
@objc func didAddContact(notification : Notification) {
Contact *contact = (Contact *)notification.object;
// add contact object to your contactsArray 

}

@objc func didRemoveContact(notification : Notification) {
Contact *contact = (Contact *)notification.object;
// remove contact object from your contactsArray
}

@objc func didUpdateContact(notification : Notification) {
NSDictionary *userInfo = (NSDictionary *)notification.object;
Contact *contact = [userInfo objectForKey:kContactKey];
// update the contact object in your contacts array, new informations like the contact
// avatar image might be sent by the server after the initial addContact.
// update contact list when user remove/add contact from his network using other clients
}

```






