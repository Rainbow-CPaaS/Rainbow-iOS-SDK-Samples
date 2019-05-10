//
//  ChannelInfoViewController.h
//  RainbowiOSSDKChannels
//
//  Created by Vladimir Vyskocil on 09/05/2019.
//  Copyright © 2019 ALE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rainbow/Rainbow.h>

@interface ChannelInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) Channel *channel;

@end
