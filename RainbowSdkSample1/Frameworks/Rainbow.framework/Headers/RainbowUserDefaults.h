/*
 * Rainbow
 *
 * Copyright (c) 2016, ALE International
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

@interface RainbowUserDefaults : NSUserDefaults

/**
 *  Set the suite name to use when init of NSUserDefaults, if nil we use the standart defaults
 */
+(void) setSuiteName:(NSString *) newSuiteName;

/**
 *  Return a shared instance of user defaults
 */
+(RainbowUserDefaults*) sharedInstance;

@end
