//
//  CallViewController.h
//  RainbowSdkSample2
//
//  Created by Vladimir Vyskocil on 11/04/2018.
//  Copyright © 2018 ALE. All rights reserved.
//

#import <Rainbow/Rainbow.h>
#import <UIKit/UIKit.h>

@interface CallViewController : UIViewController
@property (nonatomic, strong) Contact *contact;
@property (nonatomic, strong) UIImage *contactImage;
@property (nonatomic, strong) UIColor *contactImageTint;
@end
