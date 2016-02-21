//
//  MapViewCotroller.h
//  GetImageFromInstagram
//
//  Created by Home on 1/2/16.
//  Copyright (c) 2016 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DatabaseHelper.h"

@interface MapViewCotroller : UIViewController<MKMapViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapp;
@property (strong, nonatomic) DatabaseHelper *databaseHelper;

-(IBAction) nextClicked:(id) sender;

-(IBAction)backClicked:(id)sender;

@end
