//
//  CreateChannelViewController.m
//  RainbowiOSSDKChannels
//
//  Created by Vladimir Vyskocil on 03/04/2019.
//  Copyright © 2019 ALE. All rights reserved.
//

#import "CreateChannelViewController.h"

@interface CreateChannelViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UITextField *descriptionTextField;

@end

@implementation CreateChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(IBAction)openImagePicker:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = true;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion: nil];
    } else {
        UIAlertController *alert  = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You are not allowed to open the image library" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction: [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion: nil];
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    if(info[UIImagePickerControllerOriginalImage]){
        _avatarImageView.image = info[UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
