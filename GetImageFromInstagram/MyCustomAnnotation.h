//
//  MyCustomAnnotation.h
//  CustomDisplayMap
//
//  Created by Home on 11/28/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyCustomAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSURL *urlImage;
//@property (strong, nonatomic) NSMutableArray *captions;
//@property (strong, nonatomic) NSMutableArray *usernames;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;
// Other methods and properties.
@end


