//
//  ViewController.m
//  GetImageFromInstagram
//
//  Created by Home on 12/10/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "MainViewController.h"
#import "InstagramEngine.h"
#import "InstagramKitConstants.h"
#import "InstagramPaginationInfo.h"
#import "IKCell.h"
#import "MyAnnotation.h"

#define kNumberOfCellsInARow 3
#define kFetchItemsCount 15

@interface MainViewController()

@property (nonatomic, weak) MyAnnotation *myAnnotation;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, strong)   NSMutableArray *mediaArray;
@property (nonatomic, strong) NSMutableArray *mLocations;
@property (nonatomic, weak)     InstagramEngine *instagramEngine;
@property (nonatomic, strong)   InstagramPaginationInfo *currentPaginationInfo;



@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
    
    self.mediaArray = [[NSMutableArray alloc] init];
    self.mLocations = [[NSMutableArray alloc] init];
    self.instagramEngine = [InstagramEngine sharedEngine];
    [self updateCollectionViewLayout];
    
    [self loadMedia];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAuthenticationChanged:)
                                                 name:InstagramKitUserAuthenticationChangedNotification
                                               object:nil];
    
}

/**
 *  Depending on whether the Instagram session is authenticated,
 *  this method loads either the publicly accessible popular media
 *  or the authenticated user's feed.
 */
- (void)loadMedia
{
    //self.currentPaginationInfo = nil;
    
    BOOL isSessionValid = [self.instagramEngine isSessionValid];
    [self setTitle: (isSessionValid) ? @"My Feed" : @"Popular Media"];
    [self.navigationItem.leftBarButtonItem setTitle: (isSessionValid) ? @"Log out" : @"Log in"];
    [self.navigationItem.rightBarButtonItem setTitle:@"Tag Search"];
    [self.mediaArray removeAllObjects];
    [self.collectionView reloadData];
    
    if (isSessionValid) {
        [self requestSelfFeed];
    }
    else
    {
        [self requestPopularMedia];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Authenticated Notification -


- (void)userAuthenticationChanged:(NSNotification *)notification
{
    [self loadMedia];
}


/**
 Invoked when user taps the left navigation item.
 @discussion Either directs to the Login ViewController or logs out.
 */
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


-(IBAction)unwindSegue:(UIStoryboardSegue *)sender
{
    [sender.sourceViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)changeTagTapped:(id)sender
{
    NSLog(@"Tag Search was Tapped");
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
         [self.collectionView reloadData];
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
                                           
                                           self.currentPaginationInfo = paginationInfo;
                                           [self.mediaArray addObjectsFromArray:media];
                                           
                                           for (InstagramMedia *mediator in media) {
                                               CLLocation *location = [[CLLocation alloc] initWithLatitude:mediator.location.latitude longitude:mediator.location.longitude];
                                               [self.mLocations addObject:location];
                                           }
                                           
                                           [self.collectionView reloadData];
                                           [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.mediaArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
                                           
                                       }
                                       failure:^(NSError *error, NSInteger statusCode) {
                                           NSLog(@"Request Self Feed Failed");
                                       }];
}


#pragma mark - UICollectionViewDataSource Methods -


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mediaArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IKCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPCELL" forIndexPath:indexPath];
    InstagramMedia *media = self.mediaArray[indexPath.row];
    [cell setImageUrl:media.thumbnailURL];
    return cell;
}

- (void)updateCollectionViewLayout
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat size = floor((CGRectGetWidth(self.collectionView.bounds)-1) / kNumberOfCellsInARow);
    layout.itemSize = CGSizeMake(size, size);
}

@end
