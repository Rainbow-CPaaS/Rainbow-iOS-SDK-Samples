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
/**
 *  Phone number type
 */
typedef NS_ENUM(NSInteger, PhoneNumberType) {
    /**
     *  Phone number type Home
     */
    PhoneNumberTypeHome = 0,
    /**
     *  Phone number type Work
     */
    PhoneNumberTypeWork,
    /**
     * Phone number type Conference (used by PSTN Conference)
     */
    PhoneNumberTypeConference,
    /**
     *  Phone number type Other
     */
    PhoneNumberTypeOther
};

/**
 *  Phone number device type
 */
typedef NS_ENUM(NSInteger, PhoneNumberDeviceType) {
    /**
     *  Phone number device type Landline
     */
    PhoneNumberDeviceTypeLandline = 0,
    /**
     *  Phone number device type Mobile
     */
    PhoneNumberDeviceTypeMobile,
    /**
     *  Phone number device type Fax
     */
    PhoneNumberDeviceTypeFax,
    /**
     *  Phone number device type Other
     */
    PhoneNumberDeviceTypeOther
};

/**
 *  Phone number object
 */
@interface PhoneNumber : NSObject

/** Phone number */
@property (nonatomic, readonly) NSString *number;

/** Phone number in E164 format */
@property (nonatomic, readonly) NSString *numberE164;

/** Phone number label */
@property (nonatomic, readonly) NSString *label;

/** Phone number type 
 *  @see PhoneNumberType 
 */
@property (nonatomic, readonly) PhoneNumberType type;

/** Phone number device type
 *  @see PhoneNumberDeviceType
 */
@property (nonatomic, readonly) PhoneNumberDeviceType deviceType;

/** Boolean value defining if this phone number is prefered */
@property (nonatomic, readonly) BOOL isPrefered;

/** Phone number country code */
@property (nonatomic, readonly) NSString *countryCode;
/** Phone country name
 *  @discussion will contain the country name of the phone number, it used for phone number of type `PhoneNumberTypeConference` to help the application to display it correctly
 */
@property (nonatomic, readonly) NSString *countryName;

/** This phone number is monitored by a PBX */
@property (nonatomic, readonly) BOOL isMonitored;

/** Boolean value indicating that the phone number must include language selection in dtmf code
 *  @discussion This boolean is used for phone number of type `PhoneNumberTypeConference` to help the application to determine if the dtmf code must contain suplementary informations
 */

@property (nonatomic, readonly) BOOL needLanguageSelection;

/**
 *  Phone number json respresentation
 *
 *  @return json respresentation of a phone number object
 */
-(NSString *) jsonRepresentation;

/**
 *  Phone number dictionary representation
 *
 *  @return Dictionary representation of a phone number object
 */
-(NSDictionary *) dictionaryRepresentation;
@end
