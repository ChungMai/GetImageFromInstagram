//
//  MyLocation.m
//  GetImageFromInstagram
//
//  Created by Home on 1/9/16.
//  Copyright (c) 2016 Home. All rights reserved.
//

#import "MyLocation.h"

@implementation MyLocation

@synthesize coordinate;

-(id) initWithLocation:(CLLocationCoordinate2D)coord
{
    coordinate = coord;
    return self;
}

@end
