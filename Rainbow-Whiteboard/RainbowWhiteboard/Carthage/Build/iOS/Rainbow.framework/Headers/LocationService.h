//
//  LocationService.h
//  Rainbow
//
//  Created by Alaa Bzour on 2/18/19.
//  Copyright © 2019 ALE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Location;
@interface LocationService : NSObject
/**
 *  Create location with latitude and longitude
 *  @param lat              the latitude float value
 *  @param lon              the longitude float value
 *
 *  @return Location         return the location
 */

-(Location *) createLocationWithLatitude:(float)latitude andLongitude:(float)longitude;

@end
