/**
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
/**
 *  Type of email address supported
 */
typedef NS_ENUM(NSInteger, EmailAddressType) {
    /**
     *  Email address of type Home
     */
    EmailAddressTypeHome = 0,
    /**
     *  Email address of type Work
     */
    EmailAddressTypeWork,
    /**
     *  Email address of type Other
     */
    EmailAddressTypeOther
};

/**
 *  Email address object
 */
@interface EmailAddress : NSObject

/** Email address */
@property (nonatomic, readonly) NSString *address;

/** Email address label */
@property (nonatomic, readonly) NSString *label;

/**
 *  Email address Type
 *  @see EmailAddressType
 */
@property (nonatomic, readonly) EmailAddressType type;

/** Boolean value defining if this email adress is prefered */
@property (nonatomic, readonly) BOOL isPrefered;

// Define if this email adress can be visible in user interface
@property (nonatomic, readonly) BOOL isVisible;

/**
 *  Return the EmailAddressType matching the given label
 *
 *  @param label the label to search
 *
 *  @return EmailAddressType that match the given label
 *  @see EmailAddressType
 */
+(EmailAddressType) typeFromEmailAddressLabel:(NSString *) label;

/**
 *  Email address json respresentation
 *
 *  @return json respresentation of an email adress object
 */
-(NSString *) jsonRepresentation;

/**
 *  Email address dictionary representation
 *
 *  @return Dictionary representation of an email address object
 */
-(NSDictionary *) dictionaryRepresentation;
@end
