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

#import "PostItemViewController.h"
#import <Rainbow/Rainbow.h>

@interface PostItemViewController ()
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;

@property (nonatomic, strong) ChannelsService *channelsManager;

@end

@implementation PostItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _channelsManager = [ServicesManager sharedInstance].channelsService;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _titleTextField.text = @"";
    _bodyTextView.text = @"";
}

- (IBAction)postAction:(id)sender {
    if(_bodyTextView.text.length > 0){
        if(_channel){
            // Channel item title is optional
            NSString *title = _titleTextField.text.length > 0 ? _titleTextField.text : nil;
            [_channelsManager addItemToChannel:_channel type:ChannelItemTypeBasic message:_bodyTextView.text title:title url:nil images:nil attachments:nil youtubeVideoId:nil completionHandler:nil];
        }
        self.channel = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
