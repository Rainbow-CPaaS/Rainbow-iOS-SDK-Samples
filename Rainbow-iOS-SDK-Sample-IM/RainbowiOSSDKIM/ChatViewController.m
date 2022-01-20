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

#import "ChatViewController.h"
#import "MyUserTableViewCell.h"
#import "PeerTableViewCell.h"

#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define kPageSize 50

@interface MessageItem : NSObject
@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) File *attachment;
@end

@implementation MessageItem
@end

@interface ChatViewController ()
@property (weak, nonatomic) IBOutlet UITableView *messageList;
@property (weak, nonatomic) IBOutlet UITextView *textInput;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) ServicesManager *serviceManager;
@property (strong, nonatomic) ConversationsManagerService *conversationsManager;
@property (strong, nonatomic) MessagesBrowser *messagesBrowser;
@property (strong, nonatomic) NSMutableArray<MessageItem *> *messages;
@property (strong, nonatomic) UIImage *myAvatar;
@property (strong, nonatomic) UIImage *peerAvatar;
@property (strong, nonatomic) Conversation *theConversation;
@property (strong, nonatomic) File *attachmentFileToSend;
@property (weak, nonatomic) IBOutlet UIImageView *attachementImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentViewHeightConstraint;
@end

@implementation ChatViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _serviceManager = [ServicesManager sharedInstance];
        _conversationsManager = [ServicesManager sharedInstance].conversationsManagerService;
        if(_serviceManager.myUser.contact.photoData){
            _myAvatar = [UIImage imageWithData: _serviceManager.myUser.contact.photoData];
        } else {
            _myAvatar = nil;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _textInput.layer.cornerRadius = 12;
    _textInput.layer.masksToBounds = YES;
    self.textInput.delegate = self;
    self.messages = [[NSMutableArray alloc] init];
    self.attachmentFileToSend = nil;
    if(self.contact.photoData){
        self.peerAvatar = [UIImage imageWithData: self.contact.photoData];
    } else {
        self.peerAvatar = nil;
    }
    
    // All conversations for myUser
    NSArray<Conversation *> *conversationsArray = self.conversationsManager.conversations;
    self.theConversation = nil;
    
    for(Conversation *conversation in conversationsArray){
        if(conversation.peer == (Peer *)self.contact){
            self.theConversation = conversation;
            break;
        }
    }
    // If there is no conversation with this peer, create a new one
    if(!self.theConversation){
        [[ServicesManager sharedInstance].conversationsManagerService startConversationWithPeer:self.contact withCompletionHandler:^(Conversation *conversation, NSError *error) {
            if(!error){
                self.theConversation = conversation;
            } else {
                NSLog(@"Can't create the new conversation, error: %@", [error description]);
            }
        }];
    }
    self.title = [NSString stringWithFormat:@"Conversation with %@", ((Contact *)self.theConversation.peer).displayName];
    self.attachmentViewHeightConstraint.constant = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:@"UIKeyboardDidHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMessage:) name:kConversationsManagerDidReceiveNewMessageForConversation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldUpdateAttachment:) name:kFileSharingServiceDidUpdateFile object:nil];
    
    self.messagesBrowser = [self.conversationsManager messagesBrowserForConversation:self.theConversation withPageSize:kPageSize preloadMessages:YES];
    self.messagesBrowser.delegate = self;
    [_messagesBrowser resyncBrowsingCacheWithCompletionHandler:^(NSArray *addedCacheItems, NSArray *removedCacheItems, NSArray *updatedCacheItems, NSError *error) {
        NSLog(@"Resync done");
    }];
}

-(void)dealloc {
     [_messagesBrowser reset];
    _messagesBrowser.delegate = nil;
    _messagesBrowser = nil;
    _messages = nil;
    _myAvatar = nil;
    _peerAvatar = nil;
    _serviceManager = nil;
    _conversationsManager = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardDidHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConversationsManagerDidReceiveNewMessageForConversation object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFileSharingServiceDidUpdateFile object:nil];
}

/*
 * Scroll the message list to the latest one when the reloadData has finished
 */
-(void)reloadAndScrollToBottom {
    if(!self.messageList.dataSource){
        // ChatViewController is being deallocated
        return;
    }
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if([self.messageList numberOfRowsInSection:0] > 0){
            NSIndexPath *lastRow = [NSIndexPath indexPathForRow:[self.messageList numberOfRowsInSection:0] - 1 inSection:0];
            [self.messageList scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }];
    [self.messageList reloadData];
    [CATransaction commit];
}

#pragma mark - IBAction

- (IBAction)sendAction:(id)sender {
    if(self.theConversation){
        self.textInput.editable = NO;
        self.sendButton.enabled = NO;
        self.attachmentViewHeightConstraint.constant = 0;
        NSArray *fileToSend = self.attachmentFileToSend ? @[self.attachmentFileToSend] : nil;
        [self.conversationsManager sendTextMessage:self.textInput.text files:fileToSend mentions:nil priority:MessagePriorityDefault repliedMessage:nil conversation:self.theConversation completionHandler:^(Message *message, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!error){
                } else {
                    NSLog(@"Can't send message to the conversation error: %@",[error description]);
                }
                self.textInput.text = @"";
                self.sendButton.enabled = NO;
                self.textInput.editable = YES;
                self.attachmentFileToSend = nil;
                [self reloadAndScrollToBottom];
            });
        }];
    }
}

- (IBAction)addAttachment:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak __typeof__(self) weakSelf = self;
 
    UIAlertAction* uploadImageFromLibraryAction = [UIAlertAction actionWithTitle: @"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [weakSelf didTapUploadImageAction:action];
    }];
    [uploadImageFromLibraryAction setValue:[[UIImage imageNamed:@"folder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
    [actionSheet addAction:uploadImageFromLibraryAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:cancelAction];
    
    // show the menu.
    [self presentViewController:actionSheet animated:YES completion:nil];
    self.textInput.editable = NO;
}

-(void) showAllowAccessPhotoAndCameraPopup {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* gotoSettingsAction = [UIAlertAction actionWithTitle:@"Go to Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    [alert addAction:gotoSettingsAction];
    
    // show the alert.
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didTapUploadImageAction:(UIAlertAction *)sender {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(status == PHAuthorizationStatusAuthorized) {
                // Already authorized
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                else
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                
                imagePickerController.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
                
                [self presentViewController:imagePickerController animated:YES completion:nil];
                
            } else {
                [self showAllowAccessPhotoAndCameraPopup];
            }
        });
    }];
}

- (IBAction)closeAttachementAction:(id)sender {
    self.attachmentViewHeightConstraint.constant = 0;
    self.textInput.editable = YES;
    _attachmentFileToSend = nil;
    [self reloadAndScrollToBottom];
}

#pragma mark - UIImagePickerControllerDelegate protocol

- (void)downloadAsset:(PHAsset *)asset toURL:(NSURL *)url completion:(void(^)(NSURL *assetVideoUrl, NSData *data))completion {
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.networkAccessAllowed = YES;
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            // Convert HEIC to JPEG for not iOS device compatibility
            if( [[url pathExtension] isEqualToString:@"HEIC"] || [[url pathExtension] isEqualToString:@"HEIF"]) {
                UIImage *im = [UIImage imageWithData:imageData];
                imageData = UIImageJPEGRepresentation(im, 0.9);
            }
            
            if ([info objectForKey:PHImageErrorKey] == nil && [[NSFileManager defaultManager] createFileAtPath:url.path contents:imageData attributes:nil]) {
                NSLog(@"downloaded photo:%@", url.path);
            }
            completion(nil, imageData);
        }];
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        [[NSFileManager defaultManager] removeItemAtPath:url.path error:nil];
        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
        options.networkAccessAllowed = YES;
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            NSURL *videoUrl = [(AVURLAsset *)asset URL];
            NSData *videoData = [NSData dataWithContentsOfURL:videoUrl options:0 error:nil];
            [videoData writeToFile:url.path atomically:YES];
            completion(videoUrl, videoData);
        }];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSURL *assetURL;
    if([info objectForKey:UIImagePickerControllerReferenceURL])
        assetURL = info[UIImagePickerControllerReferenceURL];
    else if([info objectForKey:UIImagePickerControllerMediaURL])
        assetURL = info[UIImagePickerControllerMediaURL];
    
    PHFetchResult<PHAsset *> *asset = nil;
    __block NSData *dataToSend = nil;
    __block NSURL *assetUrl = nil;
    
    if(assetURL){
        asset = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
        if(asset.count > 0){
            __block NSString* fileName = [asset.firstObject valueForKey:@"filename"];
            NSURL *cacheURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                                      [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject], [[NSUUID UUID] UUIDString]]];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [self downloadAsset:asset.firstObject toURL:cacheURL completion:^(NSURL *url, NSData *data) {
                assetUrl = url;
                dataToSend = data;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            self.attachmentFileToSend = [[ServicesManager sharedInstance].fileSharingService createTemporaryFileWithFileName:fileName andData:dataToSend andURL:cacheURL];
            self.sendButton.enabled = YES;
        }
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        self.attachmentViewHeightConstraint.constant = 70;
        [self reloadAndScrollToBottom];
        [self.attachementImageView setImage:[UIImage imageWithData:self.attachmentFileToSend.data]];
    }];
}

#pragma mark - Browsing delegate

-(void) itemsBrowser:(CKItemsBrowser*)browser didAddCacheItems:(NSArray*)newItems atIndexes:(NSIndexSet*)indexes {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self itemsBrowser:browser didAddCacheItems:newItems atIndexes:indexes];
        });
        return;
    }
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), newItems);
    @synchronized(self.messages){
        __block NSUInteger newItemIndex = 0;
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            Message *message = [newItems objectAtIndex:newItemIndex];
            MessageItem *item = [[MessageItem alloc] init];
            if (message.isOutgoing) {
                item.contact = self.serviceManager.myUser.contact;
                
            } else {
                item.contact = (Contact *)message.peer;
            }
            item.attachment = message.attachment;
            item.text = message.body;
            [self.messages insertObject:item atIndex:idx];
            newItemIndex++;
        }];
    }
    [self reloadAndScrollToBottom];
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didRemoveCacheItems:(NSArray*)removedItems atIndexes:(NSIndexSet*)indexes {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self itemsBrowser:browser didRemoveCacheItems:removedItems atIndexes:indexes];
        });
        return;
    }
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), removedItems);
    @synchronized(self.messages){
        NSMutableIndexSet *validatedIndexes = [NSMutableIndexSet indexSet];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            if(idx < self.messages.count){
                [validatedIndexes addIndex:idx];
            }
        }];
        [self.messages removeObjectsAtIndexes:validatedIndexes];
    }
    [self reloadAndScrollToBottom];
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didUpdateCacheItems:(NSArray*)changedItems atIndexes:(NSIndexSet*)indexes {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self itemsBrowser:browser didUpdateCacheItems:changedItems atIndexes:indexes];
        });
        return;
    }
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), changedItems);
    @synchronized(self.messages){
        __block NSUInteger changedItemIndex = 0;
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            Message *message = [changedItems objectAtIndex:changedItemIndex];
            MessageItem *item = [[MessageItem alloc] init];
            if(message.isOutgoing){
                item.contact = self.serviceManager.myUser.contact;
            } else {
                item.contact = (Contact *)message.peer;
            }
            item.text = message.body;
            item.attachment = message.attachment;
            [self.messages replaceObjectAtIndex:changedItemIndex withObject:item];
            changedItemIndex++;
        }];
    }
    [self reloadAndScrollToBottom];
    
}

-(void) itemsBrowser:(CKItemsBrowser*)browser didReorderCacheItemsAtIndexes:(NSArray*)oldIndexes toIndexes:(NSArray*)newIndexes {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self itemsBrowser:browser didReorderCacheItemsAtIndexes:oldIndexes toIndexes:newIndexes];
        });
        return;
    }
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void) itemsBrowser:(CKItemsBrowser *)browser didReceiveItemsAddedEvent:(NSArray *)addedItems {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self itemsBrowser:browser didReceiveItemsAddedEvent:addedItems];
        });
        return;
    }
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - UITextviewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.sendButton.enabled = textView.text.length > 0 ? YES : NO;
}

#pragma mark - Conversation manager notification

- (void) didReceiveNewMessage: (NSNotification *) notification {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didReceiveNewMessage:notification];
        });
        return;
    }
    
    Conversation * receivedConversation  = notification.object;
    if(receivedConversation == self.theConversation){
        NSLog(@"did received new message for the conversation");
    }
}

-(void) shouldUpdateAttachment:(NSNotification *) notification {
    // The updated file is in the notification object,
    // but in the sample code we reload the whole conversation
    File *file = notification.object;
    NSLog(@"[shouldUpdateAttachment] file=%@ mimeType=%@ URL=%@ hasThumbnailData=%@", file.fileName, file.mimeType, file.url, file.thumbnailData!=nil?@"yes":@"no");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadAndScrollToBottom];
    });
}
#pragma mark - Keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification{
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self keyboardWillShow:notification];
        });
        return;
    }
    [UIView beginAnimations:nil context:nil];
    NSDictionary *userInfo = notification.userInfo;
    NSValue *keyboardFrame = [userInfo valueForKey: UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRectangle = [keyboardFrame CGRectValue];
    self.view.frame = CGRectMake(0,  - keyboardRectangle.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (void)keyboardDidHide:(NSNotification *)notification{
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self keyboardDidHide:notification];
        });
        return;
    }
    [UIView beginAnimations:nil context:nil];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = self.messages.count - indexPath.row - 1;
    if (self.messages[row].contact == _serviceManager.myUser.contact){
        return [tableView dequeueReusableCellWithIdentifier:@"MyUserTableViewCell" forIndexPath:indexPath];
    } else {
        return [tableView dequeueReusableCellWithIdentifier:@"PeerTableViewCell" forIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = self.messages.count - indexPath.row - 1;
    if([cell isKindOfClass:[MyUserTableViewCell class]]){
        MyUserTableViewCell  *myCell = (MyUserTableViewCell *)cell;
        if(self.myAvatar){
            myCell.avatar.image = self.myAvatar;
        }
        myCell.message.text = self.messages[row].text;
        if(self.messages[row].attachment && self.messages[row].attachment.thumbnailData){
            myCell.attachmentPreview.image = [UIImage imageWithData:self.messages[row].attachment.thumbnailData];
            myCell.attachmentPreview.hidden = NO;
            myCell.attachmentHeight.constant = 80;
            myCell.message.text = @"";
        }
        else if (self.messages[row].attachment) {
            myCell.message.text = self.messages[row].attachment.fileName;
        }
        else {
            myCell.attachmentPreview.hidden = YES;
            myCell.attachmentHeight.constant = 0;
        }
    } else {
        PeerTableViewCell *peerCell = (PeerTableViewCell *)cell;
        if(self.peerAvatar){
            peerCell.avatar.image = self.peerAvatar;
        }
        peerCell.message.text = self.messages[row].text;
        if(self.messages[row].attachment && self.messages[row].attachment.thumbnailData){
            peerCell.attachmentPreview.image = [UIImage imageWithData:self.messages[row].attachment.thumbnailData];
            peerCell.attachmentPreview.hidden = NO;
            peerCell.attachmentHeight.constant = 80;
            peerCell.message.text = @"";
        }
        else if (self.messages[row].attachment) {
            peerCell.message.text = self.messages[row].attachment.fileName;
        }
        else {
            peerCell.attachmentPreview.hidden = YES;
            peerCell.attachmentHeight.constant = 0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = self.messages.count - indexPath.row - 1;
    if(self.messages[row].attachment && self.messages[row].attachment.thumbnailData){
        return 60 + 80;
    } else {
        return 80;
    }
}

@end
