/*
 * Rainbow
 *
 * Copyright (c) 2017, ALE International
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

#import <Foundation/Foundation.h>
#import "CKItemsBrowser.h"

/**
 Monitors host connectivity to recover from connection lost and keep a browser up to date.
 If the add-on detects new items during resync, it will explicitely call back its browser delegate 
 with the callback `itemsBrowser:didReceiveItemsAddedEvent:` so that, from the delegate perspective, 
 those added items are perceived as "live added events".
 N.B: the browser resync phasis is performed as a long running task so that it can be properly executed
 in background.
 */
@interface MessagesAlwaysInSyncBrowserAddOn : NSObject

/** The browser associated to this add-on. */
@property (nonatomic, strong) CKItemsBrowser* browser;

@end
