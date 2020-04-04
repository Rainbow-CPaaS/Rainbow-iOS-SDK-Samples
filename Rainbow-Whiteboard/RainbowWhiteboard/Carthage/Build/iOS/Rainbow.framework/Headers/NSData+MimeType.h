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
NS_ASSUME_NONNULL_BEGIN
@interface NSData (MimeType)
- (NSString *)mimeTypeByGuessing;
-(NSString *) extension;
@end
NS_ASSUME_NONNULL_END
