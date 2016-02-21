//
//  InstagramMedia.h
//  GetImageFromInstagram
//
//  Created by Home on 12/13/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "InstagramModel.h"

@class InstagramComment;
@class InstagramUser;
@class InstagramLocation;

@interface InstagramMedia : InstagramModel<NSCopying, NSSecureCoding, NSObject>

@property (nonatomic, readonly) InstagramUser *user;

/**
 *  Is Media liked by the authenticated user.
 */
@property (nonatomic) BOOL userHasLiked;

/**
 *  Date of creation of Media.
 */
@property (nonatomic, readonly) NSDate *createdDate;

/**
 *  Web Link to the Media.
 */
@property (nonatomic, readonly) NSString* link;

/**
 *  Caption created by creator of the Media.
 */
@property (nonatomic, readonly) InstagramComment* caption;

/**
 *  Number of likes on the Media.
 */
@property (nonatomic, readonly) NSInteger likesCount;

/**
 *  List of users who have liked the Media.
 */
@property (nonatomic, readonly) NSArray *likes;

/**
 *  Number of comments on the Media.
 */
@property (nonatomic, readonly) NSInteger commentCount;

/**
 *  An array of comments on the Media.
 */
@property (nonatomic, readonly) NSArray *comments;

/**
 *  Tags on the Media.
 */
@property (nonatomic, readonly) NSArray *tags;

/**
 *  Media Location coordinates
 */
@property (nonatomic, readonly) CLLocationCoordinate2D location;

/**
 *  Media Location id.
 */
@property (nonatomic, readonly) NSString *locationId;

/**
 *  Media Location name.
 */
@property (nonatomic, readonly) NSString *locationName;

/**
 *  Filter applied on Media during creation.
 */
@property (nonatomic, readonly) NSString *filter;

/**
 *  Link to the thumbnail image of the Media.
 */
@property (nonatomic, readonly) NSURL *thumbnailURL;

/**
 *  Size of the thumbnail image frame.
 */
@property (nonatomic, readonly) CGSize thumbnailFrameSize;

/**
 *  Link to the low resolution image of the Media.
 */
@property (nonatomic, readonly) NSURL *lowResolutionImageURL;

/**
 *  Size of the low resolution image frame.
 */
@property (nonatomic, readonly) CGSize lowResolutionImageFrameSize;

/**
 *  Link to the standard resolution image of the Media.
 */
@property (nonatomic, readonly) NSURL *standardResolutionImageURL;

/**
 *  Size of the standard resolution image frame.
 */
@property (nonatomic, readonly) CGSize standardResolutionImageFrameSize;

/**
 *  Indicates if Media is a video.
 */
@property (nonatomic, readonly) BOOL isVideo;

/**
 *  Link to the low resolution video of the Media, if Media is a video.
 */
@property (nonatomic, readonly) NSURL *lowResolutionVideoURL;

/**
 *  Size of the low resolution video frame.
 */
@property (nonatomic, readonly) CGSize lowResolutionVideoFrameSize;

/**
 *  Link to the standard resolution video of the Media, if Media is a video.
 */
@property (nonatomic, readonly) NSURL *standardResolutionVideoURL;

/**
 *  Size of the standard resolution video frame.
 */
@property (nonatomic, readonly) CGSize standardResolutionVideoFrameSize;

@end
