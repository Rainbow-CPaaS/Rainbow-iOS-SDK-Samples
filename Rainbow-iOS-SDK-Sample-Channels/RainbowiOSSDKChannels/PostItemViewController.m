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

@end

@implementation PostItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)postAction:(id)sender {
    if(_titleTextField.text.length > 0 && _bodyTextView.text.length > 0){
        ChannelItem *item = [[ChannelItem alloc] init];
    }
}

@end
