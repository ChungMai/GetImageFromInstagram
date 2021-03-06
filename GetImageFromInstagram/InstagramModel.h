//
//  InstagramModel.h
//  GetImageFromInstagram
//
//  Created by Home on 12/21/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstagramKitConstants.h"


/**
 *  JSON keys as string constants.
 */
INSTAGRAMKIT_EXTERN NSString *const kID;
INSTAGRAMKIT_EXTERN NSString *const kCount;
INSTAGRAMKIT_EXTERN NSString *const kURL;
INSTAGRAMKIT_EXTERN NSString *const kHeight;
INSTAGRAMKIT_EXTERN NSString *const kWidth;
INSTAGRAMKIT_EXTERN NSString *const kData;

INSTAGRAMKIT_EXTERN NSString *const kThumbnail;
INSTAGRAMKIT_EXTERN NSString *const kLowResolution;
INSTAGRAMKIT_EXTERN NSString *const kStandardResolution;

INSTAGRAMKIT_EXTERN NSString *const kMediaTypeImage;
INSTAGRAMKIT_EXTERN NSString *const kMediaTypeVideo;

INSTAGRAMKIT_EXTERN NSString *const kUser;
INSTAGRAMKIT_EXTERN NSString *const kUserHasLiked;
INSTAGRAMKIT_EXTERN NSString *const kCreatedDate;
INSTAGRAMKIT_EXTERN NSString *const kLink;
INSTAGRAMKIT_EXTERN NSString *const kCaption;
INSTAGRAMKIT_EXTERN NSString *const kLikes;
INSTAGRAMKIT_EXTERN NSString *const kComments;
INSTAGRAMKIT_EXTERN NSString *const kFilter;
INSTAGRAMKIT_EXTERN NSString *const kTags;
INSTAGRAMKIT_EXTERN NSString *const kImages;
INSTAGRAMKIT_EXTERN NSString *const kVideos;
INSTAGRAMKIT_EXTERN NSString *const kLocation;
INSTAGRAMKIT_EXTERN NSString *const kType;

INSTAGRAMKIT_EXTERN NSString *const kCreator;
INSTAGRAMKIT_EXTERN NSString *const kText;

INSTAGRAMKIT_EXTERN NSString *const kUsername;
INSTAGRAMKIT_EXTERN NSString *const kFullName;
INSTAGRAMKIT_EXTERN NSString *const kFirstName;
INSTAGRAMKIT_EXTERN NSString *const kLastName;
INSTAGRAMKIT_EXTERN NSString *const kProfilePictureURL;
INSTAGRAMKIT_EXTERN NSString *const kBio;
INSTAGRAMKIT_EXTERN NSString *const kWebsite;

INSTAGRAMKIT_EXTERN NSString *const kCounts;
INSTAGRAMKIT_EXTERN NSString *const kCountMedia;
INSTAGRAMKIT_EXTERN NSString *const kCountFollows;
INSTAGRAMKIT_EXTERN NSString *const kCountFollowedBy;

INSTAGRAMKIT_EXTERN NSString *const kTagMediaCount;
INSTAGRAMKIT_EXTERN NSString *const kTagName;

INSTAGRAMKIT_EXTERN NSString *const kLocationLatitude;
INSTAGRAMKIT_EXTERN NSString *const kLocationLongitude;
INSTAGRAMKIT_EXTERN NSString *const kLocationName;


@interface InstagramModel : NSObject<NSCopying, NSSecureCoding, NSObject>

/*
 Uquine field for each object
 */
@property (readonly) NSString *Id;

-(instancetype) initWithInfo: (NSDictionary *) info;

-(BOOL) isEqualToModel: (InstagramModel *) model;

@end
