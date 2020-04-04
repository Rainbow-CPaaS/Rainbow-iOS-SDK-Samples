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
 *  Server object
 */
@interface Server : NSObject
/** Server name to display */
@property (nonatomic, readonly) NSString *serverDisplayedName;
/** Boolean value set to `YES` if the server is the default one */
@property (nonatomic, readonly) BOOL defaultServer;

+(Server *) redServer;
/** Return the value `YES` if the user is connected on the Red environment */
-(BOOL) isRedServer;

/** Return the value `YES` if the user is connected on the pre-production environment */
-(BOOL) isNetServer;

/** Return the value `YES` if the user is connected on the qa pre-production environment */
-(BOOL) isQANetServer;

/** Return the value `YES` if the user is connected on the production environment */
-(BOOL) isComServer;

/** Return the value `YES` if the user is connected on the China environment */
-(BOOL) isCNServer;

/** Return the value `YES` if the user is connected on the Healthcare environment */
-(BOOL) isHDSServer;

@end
