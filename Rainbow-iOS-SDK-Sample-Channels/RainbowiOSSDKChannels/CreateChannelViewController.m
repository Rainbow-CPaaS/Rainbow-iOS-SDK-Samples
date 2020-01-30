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

#import "CreateChannelViewController.h"

#import <Rainbow/Rainbow.h>
#import <Rainbow/ChannelsService.h>

@interface CreateChannelViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UITextField *descriptionTextField;
@property (nonatomic, weak) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *closedOrPublicSwitch;
@property (nonatomic, weak) IBOutlet UIButton *createButton;

@property (nonatomic, strong) ServicesManager *serviceManager;
@property (nonatomic, strong) ChannelsService *channelsManager;
@end

@implementation CreateChannelViewController

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        _serviceManager = [ServicesManager sharedInstance];
        _channelsManager = _serviceManager.channelsService;
    }
    return self;
}

-(void)dealloc {
    _serviceManager = nil;
    _channelsManager = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - IBActions

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

- (IBAction)createAction:(id)sender {
    void (^block)(Channel *channel, NSError *error) = ^void (Channel *channel, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                [self.channelsManager updateChannel:channel.id avatar:self.avatarImageView.image completionHandler:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(error){
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                            [alert addAction:okAction];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    });
                }];
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    };
    
    if(_titleTextField.text.length > 0 && _descriptionTextField.text.length > 0){
        if(_closedOrPublicSwitch.selectedSegmentIndex == 0){
            [_channelsManager createClosedChannel:_titleTextField.text description:_descriptionTextField.text category:_categoryTextField.text maxItems: -1 autoprov:NO completionHandler:^(Channel *channel, NSError *error) {
                block(channel, error);
            }];
        } else {
            [_channelsManager createPublicChannel:_titleTextField.text description:_descriptionTextField.text category:_categoryTextField.text maxItems: -1 completionHandler:^(Channel *channel, NSError *error) {
                block(channel, error);
            }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    if(info[UIImagePickerControllerOriginalImage]){
        _avatarImageView.image = info[UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
