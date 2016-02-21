//
//  MyCustomAnnotation.m
//  CustomDisplayMap
//
//  Created by Home on 11/28/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "MyCustomAnnotation.h"

@implementation MyCustomAnnotation
@synthesize coordinate;
- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}
@end