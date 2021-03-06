//
//  MyAnnotation.h
//  GetImageFromInstagram
//
//  Created by Home on 1/2/16.
//  Copyright (c) 2016 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject<MKAnnotation>
{
    
    CLLocationCoordinate2D  coordinate;
    NSString*               title;
    NSString*               subtitle;
}

@property (nonatomic, assign)CLLocationCoordinate2D coordinate;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *subtitle;

@end
