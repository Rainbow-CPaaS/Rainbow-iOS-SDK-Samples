/*
 * Rainbow SDK sample
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

#import "UIImage+Room.h"

@implementation UIImage(Room)

+ (UIColor *) colorFromHexa:(int)hexaCode {
    return [UIColor colorWithRed:((hexaCode & 0xFF000000) >> 24) / 255.0f
                           green:((hexaCode & 0x00FF0000) >> 16) /255.0f
                            blue:((hexaCode & 0x0000FF00) >> 8) / 255.0f
                           alpha:(hexaCode & 0x000000FF)/255.0f];
}

+(UIColor*) colorForString:(NSString*) string {
    NSArray* colors = @[@0xFF4500FF, @0xD38700FF, @0x348833FF, @0x007356FF, @0x00B2A9FF, @0x00B0E5FF, @0x0085CAFF, @0x6639B7FF, @0x91278AFF, @0xCF0072FF, @0xA50034FF, @0xD20000FF];
    
    NSString* capitalizedString = [string uppercaseString];
    int sum = 0;
    for (int i=0; i< capitalizedString.length; i++) {
        sum += [capitalizedString characterAtIndex:i];
    }
    NSInteger value = [colors[0 + sum%[colors count]] integerValue];
    UIColor* color = [UIImage colorFromHexa:(int)value];
    return color;
}

/**
 *  This function returns the correct UIImage for a given contact.
 *  It returns the photoData if exists, or a default avatar in a
 *  generated color.
 *
 *  @param contact The contact
 *
 *  @return The avatar UIImage
 */
+(UIImage *) avatarForContact:(Contact *) contact {
    if(contact.photoData) {
        UIImage *image = [[UIImage alloc] initWithData:contact.photoData];
        return image;
    }
    UIColor* color = [UIColor lightGrayColor];
    if (contact.displayName) {
        color = [UIImage colorForString:contact.displayName];
    }
    UIImage *image = [[UIImage imageNamed:@"Default_Avatar"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    CGImageRef maskImage = image.CGImage;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGRect bounds = CGRectMake(0, 0, width, height);
        
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
        
    CGContextClipToMask(bitmapContext, bounds, maskImage);
    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
    CGContextFillRect(bitmapContext, bounds);
        
    CGImageRef cImage = CGBitmapContextCreateImage(bitmapContext);
    return [UIImage imageWithCGImage: cImage];
}

+(UIImage *) cropImage:(UIImage *) image withRect:(CGRect) croprect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(croprect.origin.x * image.scale,
                                                                                   croprect.origin.y * image.scale,
                                                                                   croprect.size.width * image.scale,
                                                                                   croprect.size.height * image.scale));
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

+(UIImage *) drawPhotoFromOrderedList:(NSOrderedSet*) orderedList {
    if ([orderedList count] == 0) {
        return [UIImage imageNamed:@"Default_Avatar"];
    }
    
    CGSize newSize = CGSizeMake(128, 128);
    
    if ([orderedList count] == 1) {
        
        UIImage *img1, *img2 = nil;
        id obj = orderedList[0];
        if([obj isKindOfClass:[Participant class]]) {
            img1 = [UIImage avatarForContact:((Participant*)obj).contact];
            img2 = [UIImage avatarForContact:nil];
            
            // Now open our CG context for our image.
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
            
            // participant 1 : left half of the avatar
            CGRect rect1 = CGRectMake(img1.size.width/4, 0, img1.size.width/2, img1.size.height);
            UIImage *croppedImg1 = [self cropImage:img1 withRect:rect1];
            [croppedImg1 drawInRect:CGRectMake(0, 0, newSize.width/2, newSize.height)];
            
            // participant 2 : right half of the avatar
            CGRect rect2 = CGRectMake(img2.size.width/4, 0, img2.size.width/2, img2.size.height);
            UIImage *croppedImg2 = [self cropImage:img2 withRect:rect2];
            [croppedImg2 drawInRect:CGRectMake(newSize.width/2, 0, newSize.width/2, newSize.height)];
            
            UIImage *generatedImageFromParticipants = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            return generatedImageFromParticipants;
            
            
        } else {
            return [UIImage imageNamed:@"Default_Avatar"];
        }
    }
    
    if ([orderedList count] == 2) {
        
        UIImage *img1, *img2 = nil;
        id obj0 = orderedList[0];
        id obj1 = orderedList[1];
        if([obj0 isKindOfClass:[Participant class]] && [obj1 isKindOfClass:[Participant class]]){
            // This will open its own CG context.
            img1 = [UIImage avatarForContact:((Participant*)obj0).contact];
            img2 = [UIImage avatarForContact:((Participant*)obj1).contact];
        } else {
            // This will open its own CG context.
            img1 = [UIImage avatarForContact:obj0];
            img2 = [UIImage avatarForContact:obj1];
        }
        
        // Now open our CG context for our image.
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
        
        // participant 1 : left half of the avatar
        CGRect rect1 = CGRectMake(img1.size.width/4, 0, img1.size.width/2, img1.size.height);
        UIImage *croppedImg1 = [self cropImage:img1 withRect:rect1];
        [croppedImg1 drawInRect:CGRectMake(0, 0, newSize.width/2, newSize.height)];
        
        // participant 2 : right half of the avatar
        CGRect rect2 = CGRectMake(img2.size.width/4, 0, img2.size.width/2, img2.size.height);
        UIImage *croppedImg2 = [self cropImage:img2 withRect:rect2];
        [croppedImg2 drawInRect:CGRectMake(newSize.width/2, 0, newSize.width/2, newSize.height)];
        
        UIImage *generatedImageFromParticipants = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return generatedImageFromParticipants;
    }
    
    UIImage *img1, *img2 , *img3 = nil;
    id obj0 = orderedList[0];
    id obj1 = orderedList[1];
    id obj2 = orderedList[2];
    if([obj0 isKindOfClass:[Participant class]] && [obj1 isKindOfClass:[Participant class]] && [obj2 isKindOfClass:[Participant class]]){
        // This will open its own CG context.
        img1 = [UIImage avatarForContact:((Participant*)obj0).contact];
        img2 = [UIImage avatarForContact:((Participant*)obj1).contact];
        img3 = [UIImage avatarForContact:((Participant*)obj2).contact];
    } else {
        // This will open its own CG context.
        img1 = [UIImage avatarForContact:obj0];
        img2 = [UIImage avatarForContact:obj1];
        img3 = [UIImage avatarForContact:obj2];
    }
    
    // Now open our CG context for our image.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    
    // participant 1 : left half of the avatar
    CGRect rect1 = CGRectMake(img1.size.width/4, 0, img1.size.width/2, img1.size.height);
    UIImage *croppedImg1 = [self cropImage:img1 withRect:rect1];
    [croppedImg1 drawInRect:CGRectMake(0, 0, newSize.width/2, newSize.height)];
    
    // participant 2 : right top quarter of the avatar
    [img2 drawInRect:CGRectMake(newSize.width/2, 0, newSize.width/2, newSize.height/2)];
    
    // participant 3 : right bottom quarter of the avatar
    [img3 drawInRect:CGRectMake(newSize.width/2, newSize.height/2, newSize.width/2, newSize.height/2)];
    
    UIImage *generatedImageFromParticipants = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return generatedImageFromParticipants;
}

+(UIImage *)avatarForRoom:(Room *)room {
    // If defined, display the custom avatar
    if( room.photoData != nil ) {
        UIImage *image = [[UIImage alloc] initWithData:room.photoData];
        return image;
    }
    
    // Build the avatar only with the accepted participants only if it's not my room else use all participants list
    NSMutableOrderedSet<Participant *> *participantsToDisplay = nil;
    
    if(room.isMyRoom){
        participantsToDisplay = [NSMutableOrderedSet orderedSetWithArray:[[room participants] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Participant *evaluatedObject, NSDictionary<NSString *,id> * bindings) {
            return (evaluatedObject.status != ParticipantStatusUnsubscribed) && (evaluatedObject.status != ParticipantStatusDeleted) && (evaluatedObject.status != ParticipantStatusRejected);
        }]]];
        
        Participant *myParticipant = [room participantFromContact:[ServicesManager sharedInstance].myUser.contact];
        
        
        if(myParticipant && ![participantsToDisplay containsObject:myParticipant]){
            // Not in participant list add myself in this list
            [participantsToDisplay insertObject:myParticipant atIndex:0];
        }
        
    } else {
        participantsToDisplay = [NSMutableOrderedSet orderedSetWithArray:[[room participants] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Participant *evaluatedObject, NSDictionary<NSString *,id> * bindings) {
            if ((evaluatedObject.status == ParticipantStatusUnsubscribed) && (evaluatedObject.privilege == ParticipantPrivilegeOwner)) {
                return (evaluatedObject.status == ParticipantStatusUnsubscribed) && (evaluatedObject.privilege == ParticipantPrivilegeOwner);
            }
            
            return (evaluatedObject.status != ParticipantStatusUnsubscribed) && (evaluatedObject.status != ParticipantStatusDeleted) && (evaluatedObject.status != ParticipantStatusRejected);
        }]]];
        
        for (Participant * aParticipant in participantsToDisplay) {
            if (aParticipant.privilege == ParticipantPrivilegeOwner && aParticipant.status == ParticipantStatusUnsubscribed) {
                [participantsToDisplay removeAllObjects];
                [participantsToDisplay addObject:aParticipant];
                break;
            }
        }
    }
    
    [participantsToDisplay sortUsingComparator:^NSComparisonResult(Participant *obj1, Participant *obj2) {
        if([obj1.addedDate isLaterThanDate:obj2.addedDate])
            return NSOrderedDescending;
        return NSOrderedAscending;
    }];
    
    // If the first participant to display is not the owner, loop to find him and place at the first place
    if (participantsToDisplay.firstObject && participantsToDisplay.firstObject.privilege != ParticipantPrivilegeOwner) {
        for (Participant * aParticipant in participantsToDisplay) {
            if (aParticipant.privilege == ParticipantPrivilegeOwner) {
                [participantsToDisplay removeObject:aParticipant];
                [participantsToDisplay insertObject:aParticipant atIndex:0];
                break;
            }
        }
    }
    
    return [self drawPhotoFromOrderedList:participantsToDisplay];
}

@end
