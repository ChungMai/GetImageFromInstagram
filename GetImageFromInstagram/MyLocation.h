//
//  MyLocation.h
//  GetImageFromInstagram
//
//  Created by Home on 1/9/16.
//  Copyright (c) 2016 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyLocation : NSObject
{
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithLocation: (CLLocationCoordinate2D) coordinate;

@end
