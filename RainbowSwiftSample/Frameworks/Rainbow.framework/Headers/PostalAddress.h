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

#define kPostalAddressStreetKey @"street"
#define kPostalAddressPoBoxKey @"poBox"
#define kPostalAddressZipKey @"zip"
#define kPostalAddressCityKey @"city"
#define kPostalAddressStateKey @"state"
#define kPostalAddressCountryKey @"country"
#define kPostalAddressCountryCodeKey @"countryCode"
#define kPostalAddressTypeKey @"type"
/**
 *  Postal Address Type
 */
typedef NS_ENUM(NSInteger, PostalAddressType) {
    /**
     *  Type Home
     */
    PostalAddressTypeHome = 0,
    /**
     *  Type Work
     */
    PostalAddressTypeWork
};

/**
 *  Postal address object
 */
@interface PostalAddress : NSObject
/** Post office box */
@property (nonatomic, readonly) NSString *pobox;
/** Street */
@property (nonatomic, readonly) NSString *street;
/** City */
@property (nonatomic, readonly) NSString *city;
/** State */
@property (nonatomic, readonly) NSString *state;
/** Postal code */
@property (nonatomic, readonly) NSString *postalCode;
/** Country */
@property (nonatomic, readonly) NSString *country;
/** Country code */
@property (nonatomic, readonly) NSString *countryCode;
/**
 *  Postal address type
 *  @see PostalAddressType
 */
@property (nonatomic, readonly) PostalAddressType type;

/** Postal address string representation separated by spaces */
-(NSString *) stringRepresentation;
/** Postal address dictionary representation */
-(NSDictionary *) dictionaryRepresentation;
/** Postal address json reprensentation */
-(NSString *) jsonRepresentation;
@end
