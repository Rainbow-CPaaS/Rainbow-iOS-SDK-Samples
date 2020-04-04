/*
 * Rainbow
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

#import <Foundation/Foundation.h>
#import "PhoneNumber.h"

typedef NS_ENUM(NSInteger, CallForwardType) {
    /**
     *  Type not forwarded
     */
    CallForwardTypeNotForwarded = 0,
    /**
     *  Type voicemail
     */
    CallForwardTypeVoicemail,
    /**
     *  Type phone number
     */
    CallForwardTypePhoneNumber
    
};

/**
 * CallForwardStatus
 *
 * The CallForwardStatus object represents the status of the call forware feature for the logged-in user as well as the main information to use it.
 */
@interface CallForwardStatus : NSObject

#pragma mark - Properties

/**
 * @return the type of the call forward
 */
@property (nonatomic, readonly) CallForwardType type;

/**
 * @return the destination phone number if configured
 */
@property (nonatomic, readonly) PhoneNumber *destination;

@end
