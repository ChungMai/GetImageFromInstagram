//
//  MapViewCotroller.m
//  GetImageFromInstagram
//
//  Created by Home on 1/2/16.
//  Copyright (c) 2016 Home. All rights reserved.
//

#import "MapViewCotroller.h"
#import "MyAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "InstagramEngine.h"
#import "InstagramKitConstants.h"
#import "InstagramPaginationInfo.h"
#import "IKCell.h"
#import "InstagramComment.h"
#import "InstagramUser.h"
#import "DXAnnotationView.h"
#import "DXAnnotationSettings.h"
#import "MyCustomAnnotation.h"
#import "MyLocation.h"
#import "DatabaseHelper.h"

#define kNumberOfCellsInARow 3
#define kFetchItemsCount 50

@interface MapViewCotroller()

@property(nonatomic, strong) MyCustomAnnotation* myAnnotation;
@property (nonatomic, strong)   NSMutableArray *mediaArray;
@property (nonatomic, strong) NSMutableArray *mLocations;
@property (nonatomic, weak)     InstagramEngine *instagramEngine;
@property (nonatomic, strong)   InstagramPaginationInfo *currentPaginationInfo;
@property (nonatomic, strong) NSMutableArray *locationsArray;
@property (nonatomic, strong) MyLocation *myLocation;

@end

@implementation MapViewCotroller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.databaseHelper = [[DatabaseHelper alloc] init];
    self.mediaArray = [[NSMutableArray alloc] init];
    self.mLocations = [[NSMutableArray alloc] init];
    self.locationsArray = [[NSMutableArray alloc] init];
    self.instagramEngine = [InstagramEngine sharedEngine];
    self.mapp.showsUserLocation = YES;
    self.mapp.delegate = self;
    [self loadMedia];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAuthenticationChanged:)
                                                 name:InstagramKitUserAuthenticationChangedNotification
                                               object:nil];
}

- (void)loadMedia
{
    BOOL isSessionValid = [self.instagramEngine isSessionValid];
    [self setTitle: (isSessionValid) ? @"My Feed" : @"Popular Media"];
    [self.navigationItem.leftBarButtonItem setTitle: (isSessionValid) ? @"Log out" : @"Log in"];
    [self.navigationItem.rightBarButtonItem setEnabled: isSessionValid];
    [self.mediaArray removeAllObjects];
    
    if (isSessionValid) {
        
        [self.databaseHelper dataFilePath];
        [self.databaseHelper selectTagSearch];
        self.instagramEngine.currentTagSearch = self.databaseHelper.tagSearch;
        [self requestSelfFeed];
        
    }
    else
    {
        
        [self.mapp removeAnnotations:[self.mapp annotations]];
        //[self requestPopularMedia];
    }
}

- (IBAction)loginTapped:(id)sender
{
    if (![self.instagramEngine isSessionValid]) {
        UINavigationController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
    else
    {
        [self.instagramEngine logout];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"InstagramKit" message:@"You are now logged out." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
}


- (void)userAuthenticationChanged:(NSNotification *)notification
{
    [self loadMedia];
}


-(IBAction)unwindSegue:(UIStoryboardSegue *)sender
{
    [sender.sourceViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - API Requests -

/**
 Calls InstagramKit's helper method to fetch Popular Instagram Media.
 */
- (void)requestPopularMedia
{
    [self.instagramEngine getPopularMediaWithSuccess:^(NSArray *media, InstagramPaginationInfo * paginationInfo)
     {
         [self.mediaArray addObjectsFromArray:media];
     }
    failure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"Load Popular Media Failed");
    }];
}

- (void)requestSelfFeed
{
    [self.instagramEngine getSelfFeedWithCount:kFetchItemsCount
                                         maxId:self.currentPaginationInfo.nextMaxId
                                       success:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
                                           NSLog(@"getSelfFeedWithCount");
                                           self.currentPaginationInfo = paginationInfo;
                                           [self.mediaArray addObjectsFromArray:media];
                                           
                                           MKMapRect flyTo = MKMapRectNull;
                                           
                                           for (InstagramMedia *mediator in media) {
                                               if (self.locationsArray.count == 0)
                                               {
                                                   MyLocation *mLocation = [[MyLocation alloc] initWithLocation:mediator.location];
                                                   [self.locationsArray addObject:mLocation];
                                                   
                                                   MyCustomAnnotation *mAnnotation = [[MyCustomAnnotation alloc] initWithLocation:mediator.location];
                                                   mAnnotation.title = mediator.caption.user.fullName;
                                                   mAnnotation.subtitle = mediator.locationName;
                                                   mAnnotation.urlImage = mediator.standardResolutionImageURL;
                                                   
                                                   [self.mapp addAnnotation:mAnnotation];
                                                   
                                                   MKMapPoint annotationPoint = MKMapPointForCoordinate(mLocation.coordinate);
                                                   MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
                                                   
                                                   if (MKMapRectIsNull(flyTo))
                                                   {
                                                       flyTo = pointRect;
                                                   }
                                                   else
                                                   {
                                                       flyTo = MKMapRectUnion(flyTo, pointRect);
                                                   }
                                                   //[self.annotations addObject:mAnnotation];
                                               }
                                               
                                               for (MyLocation *myLocation in self.locationsArray) {
                                                   if(myLocation.coordinate.longitude != mediator.location.longitude && myLocation.coordinate.latitude != mediator.location.latitude)
                                                   {
                                                       MyLocation *mLocation = [[MyLocation alloc] initWithLocation:mediator.location];
                                                       [self.locationsArray addObject:mLocation];
                                                       
                                                       MyCustomAnnotation *mAnnotation = [[MyCustomAnnotation alloc] initWithLocation:mediator.location];
                                                       mAnnotation.title = mediator.caption.user.fullName;
                                                       mAnnotation.subtitle = mediator.locationName;
                                                       mAnnotation.urlImage = mediator.standardResolutionImageURL;
                                                       
                                                       [self.mapp addAnnotation:mAnnotation];
                                                       //[self.annotations addObject:mAnnotation];
                                                       MKMapPoint annotationPoint = MKMapPointForCoordinate(mLocation.coordinate);
                                                       MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
                                                       
                                                       if (MKMapRectIsNull(flyTo))
                                                       {
                                                           flyTo = pointRect;
                                                       }
                                                       else
                                                       {
                                                           flyTo = MKMapRectUnion(flyTo, pointRect);
                                                       }
                                                   }  
                                                   break;
                                               }
                                           }
                                           
                                           // Set region where the images have posted                                                                   
                                           [self.mapp setVisibleMapRect:flyTo animated:YES];
                                       }
                                       failure:^(NSError *error, NSInteger statusCode) {
                                           NSLog(@"Request Self Feed Failed");
                                       }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MyCustomAnnotation class]])
    {
        MyCustomAnnotation *mAnnotation = (MyCustomAnnotation *)annotation;
        
        UIImageView *pinView = nil;
        UIView *calloutView = nil;
        
        DXAnnotationView *annotationView = (DXAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([DXAnnotationView class])];

        if (!annotationView) {
            
            // Set image to Pin
            pinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinImage.png"]];
            pinView.frame = CGRectMake(0,0,24,24);
            
            // Read UIView from the xib file
            calloutView = [[[NSBundle mainBundle] loadNibNamed:@"MyAnnotationView" owner:self options:nil] firstObject];
            
            // Set the list of images for the image view
            UIImageView *imageInstagram = (UIImageView *)[calloutView viewWithTag:2];
            __block NSMutableArray *images = [[NSMutableArray alloc] init];
            
            for (InstagramMedia *mediator in self.mediaArray) {
                if(mAnnotation.coordinate.latitude == mediator.location.latitude && mAnnotation.coordinate.longitude == mediator.location.longitude)
                {
                    __block UIImage *image = [[UIImage alloc] init];
                    
                    // Use progress background to retrieve image from the url
                    dispatch_async(dispatch_get_global_queue(0,0), ^{
                        NSData * data = [[NSData alloc] initWithContentsOfURL:mediator.standardResolutionImageURL];
                        if ( data == nil )
                            return;
                        image = [UIImage imageWithData:data];
                        image.accessibilityIdentifier = mediator.caption.text;
                        image.accessibilityValue = mediator.user.username;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [images addObject:image];
                            imageInstagram.animationImages = images;
                            [imageInstagram setImage:[imageInstagram.animationImages objectAtIndex:0]];
                            
                            UIImage *displayImage = [imageInstagram.animationImages objectAtIndex:0];
                            
                            UITextView *caption = (UITextView *)[calloutView viewWithTag:1];
                            caption.text = displayImage.accessibilityIdentifier;
                            caption.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);                            
                            UILabel *tag = (UILabel *) [calloutView viewWithTag:3];
                            tag.text = displayImage.accessibilityValue;
                        });
                    });
                }
            }
            
            annotationView = [[DXAnnotationView alloc] initWithAnnotation:annotation
                                                       reuseIdentifier:NSStringFromClass([DXAnnotationView class])
                                                       pinView:pinView
                                                       calloutView:calloutView
                                                       settings:[DXAnnotationSettings defaultSettings]];
            
            return annotationView;
        }
        return annotationView;
    }
    return nil;
}

-(IBAction)nextClicked:(id)sender
{
    // Get button clicked
    UIButton *pressedButton = (UIButton *)sender;
    
    // Get supper view of object clicked on view
    UIView *superViewOfPressedButton = pressedButton.superview;
    
    // Get current image in the list of animation images
    UIImageView *imageInstagram = (UIImageView *)[superViewOfPressedButton viewWithTag:2];
    UIImage *currentImage = imageInstagram.image;
    NSInteger index = [imageInstagram.animationImages indexOfObject:currentImage];
    
    // Set the next image for the animation images
    index = (index + 1) % [imageInstagram.animationImages count];
    [imageInstagram setImage: [imageInstagram.animationImages objectAtIndex:index]];
    
    // Set caption and who taged
    UITextView *caption = (UITextView *)[superViewOfPressedButton viewWithTag:1];
    caption.text = imageInstagram.image.accessibilityIdentifier;
    caption.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UILabel *tag = (UILabel *) [superViewOfPressedButton viewWithTag:3];
    tag.text = imageInstagram.image.accessibilityValue;
}

// Display next image
-(IBAction)backClicked:(id)sender
{
    // Get object clickeds
    UIButton *pressedButton  = (UIButton *) sender;
    
    // Get supper view of object clicked on view
    UIView *supperView = pressedButton.superview;
    
    // Get Image view
    UIImageView *imageInstagram = (UIImageView *)[supperView viewWithTag:2];
    
    // Get current image
    UIImage *currentImage = [imageInstagram image];
    NSInteger index = [imageInstagram.animationImages indexOfObject:currentImage];
    
    // Set to display the next image in animation images
    index = (index -1) % [imageInstagram.animationImages count];
    [imageInstagram setImage:[imageInstagram.animationImages objectAtIndex:index]];
    
    // Set Caption and who taged
    UITextView *caption = (UITextView *)[supperView viewWithTag:1];
    caption.text = imageInstagram.image.accessibilityIdentifier;
    caption.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UILabel *tag = (UILabel *) [supperView viewWithTag:3];
    tag.text = imageInstagram.image.accessibilityValue;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    /*if ([view isKindOfClass:[DXAnnotationView class]]) {
        [((DXAnnotationView *)view)hideCalloutView];
        view.layer.zPosition = -1;
    }*/
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[DXAnnotationView class]]) {
        [((DXAnnotationView *)view)showCalloutView];
        view.layer.zPosition = 0;
    }
}


- (IBAction)TagSearchTapped:(id)sender {
    [self.databaseHelper dataFilePath];
    [self.databaseHelper selectTagSearch];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Tag Name"
                                                 message:@"Please enter tag name that you want to search."
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Ok", nil
                       ];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [av textFieldAtIndex:0];
    textField.placeholder = [self.databaseHelper tagSearch];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
    if((int) index == 1)
    {
        NSLog(@"%@", [alertView textFieldAtIndex:0].text);
        self.databaseHelper.tagSearch = [alertView textFieldAtIndex:0].text;
        if(self.databaseHelper.tagSearch != nil && [self.databaseHelper.tagSearch length] > 0)
        {
            self.instagramEngine.currentTagSearch = [alertView textFieldAtIndex:0].text;
            [self.mapp removeAnnotations:[self.mapp annotations]];
            [self requestSelfFeed];
            [self.databaseHelper insertTag];
        }
    }
}

@end
