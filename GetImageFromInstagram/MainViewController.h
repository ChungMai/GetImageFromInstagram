//
//  ViewController.h
//  GetImageFromInstagram
//
//  Created by Home on 12/10/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MainViewController : UICollectionViewController<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapp;
-(IBAction)unwindSegue:(UIStoryboardSegue *)sender;

@end

