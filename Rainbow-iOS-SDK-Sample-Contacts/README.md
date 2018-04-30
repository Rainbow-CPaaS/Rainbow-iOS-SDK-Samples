## Rainbow SDK Sample

### Setting the development environnement 
---
For informations about development environnement you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### Login to Rainbow server
---
For informations about the login process you should look for [SDK for iOS: Getting Started](https://hub.openrainbow.com/#/documentation/doc/sdk/ios/guides/Getting_Started)

### Contact management
---
The aim of this sample project is to demonstrate Rainbow contact's management. After the login screen your actual contacts (contacts you have invited) are listed with their avatar pictures if they have set one.
You can select a contact to display more information about him like the company he belongs, his phone numbers,... 

### Retrieve the list of contacts

Once connected, you can retrieve the list of your contact as follow,

```objective-c    
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddContact:) name:kContactsManagerServiceDidAddContact object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateContact:) name:kContactsManagerServiceDidUpdateContact object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPopulatingMyNetwork:) name:kContactsManagerServiceDidEndPopulatingMyNetwork object:nil];
```

```objective-c
-(void) didAddContact:(NSNotification *) notification {
 
    Contact *contact = (Contact *)notification.object;
    // add contact object to your contactsArray 
    
}

-(void) didUpdateContact:(NSNotification *) notification {

    NSDictionary *userInfo = (NSDictionary *)notification.object;
    Contact *contact = [userInfo objectForKey:kContactKey];
    // update the contact object in your contactsArray, new informations like the contact
    // avatar image might be sent by the server after the initial addContact.
}

-(void) didEndPopulatingMyNetwork:(NSNotification *) notification {

	// the roster update is terminated
}

```

### Retrieve a contact information
The SDK retrieve and cache some informations about the connected user contacts but you could ask for all of them using `fetchRemoteContactDetail:` with the following code,

```objective-c
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetInfo:) name:kContactsManagerServiceDidUpdateContact object:nil];
  
  [[ServicesManager sharedInstance].contactsManagerService fetchRemoteContactDetail:_aContact];
```

```objective-c
-(void) didGetInfo:(NSNotification *) notification {
     Contact *contact = (Contact *)[notification.object objectForKey:@"contact"];  
}
```
