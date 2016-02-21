//
//  InstagramKitConstants.h
//  GetImageFromInstagram
//
//  Created by Home on 12/10/15.
//  Copyright (c) 2015 Home. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "InstagramPaginationInfo.h"

#ifdef __cplusplus
#define INSTAGRAMKIT_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define INSTAGRAMKIT_EXTERN extern __attribute__((visibility ("default")))
#endif

#define INSTAGRAMKIT_UICKEYCHAINSTORE __has_include("UICKeyChainStore.h")

/**
 *  Instagram API's Base URL.
 */
INSTAGRAMKIT_EXTERN NSString *const kInstagramKitBaseURL;
INSTAGRAMKIT_EXTERN NSString *const kInstagramAppClientIdConfigurationKey;
INSTAGRAMKIT_EXTERN NSString *const kInstagramAppRedirectURLConfigurationKey;
INSTAGRAMKIT_EXTERN NSString *const InstagramKitKeychainStore;
INSTAGRAMKIT_EXTERN NSString *const kInstagramKitAuthorizationURL;
INSTAGRAMKIT_EXTERN NSString *const InstagramKitErrorDomain;
INSTAGRAMKIT_EXTERN NSString *const InstagramKitUserAuthenticationChangedNotification;
INSTAGRAMKIT_EXTERN NSString *const kKeyClientID;
INSTAGRAMKIT_EXTERN NSString *const kKeyAccessToken;
INSTAGRAMKIT_EXTERN NSString *const kPagination;
INSTAGRAMKIT_EXTERN NSString *const kNextURL;
INSTAGRAMKIT_EXTERN NSString *const kNextMaxId;
INSTAGRAMKIT_EXTERN NSString *const kNextMaxLikeId;
INSTAGRAMKIT_EXTERN NSString *const kNextMaxTagId;
INSTAGRAMKIT_EXTERN NSString *const kNextCursor;
INSTAGRAMKIT_EXTERN NSString *const kPaginationKeyMaxId;

typedef void (^InstagramMediaBlock)(NSArray *media, InstagramPaginationInfo *paginationInfo);

/**
 *  A generic failure block for handling server errors.
 *
 *  @param error
 *  @param serverStatusCode
 */
typedef void (^InstagramFailureBlock)(NSError* error, NSInteger serverStatusCode);

/**
 *  A generic block used as a callback for receiving a collection of objects.
 *
 *  @param paginatedObjects Array of Instagram model objects.
 *  @param paginationInfo   A PaginationInfo object.
 */
typedef void (^InstagramPaginatiedResponseBlock)(NSArray *paginatedObjects, InstagramPaginationInfo *paginationInfo);


typedef NS_OPTIONS(NSUInteger, InstagramKitLoginScope)
{
    /*! Indicates permission to read data on a user’s behalf, e.g. recent media, following lists (granted by default) */
    InstagramKitLoginScopeBasic = 0,
    /*! Indicates permission to create or delete comments on a user’s behalf */
    InstagramKitLoginScopeComments = 1<<1,
    /*! Indicates permission to follow and unfollow accounts on a user’s behalf */
    InstagramKitLoginScopeRelationships = 1<<2,
    /*! Indicates permission to like and unlike media on a user’s behalf */
    InstagramKitLoginScopeLikes = 1<<3
};


/*!
 @typedef       NS_ENUM(NSInteger, InstagramKitErrorCode)
 @abstract      Error codes for InstagramKitErrorDomain.
 */
typedef NS_ENUM(NSInteger, InstagramKitErrorCode)
{
    /*!
     @abstract Reserved.
     */
    InstagramKitReservedError = 0,
    
    /*!
     @abstract The error code for errors from authentication failures.
     */
    InstagramKitAuthenticationFailedError,
    
    /*!
     @abstract The error code for errors when user cancels authentication.
     */
    InstagramKitAuthenticationCancelledError = NSUserCancelledError,
};


#define IKNotNull(obj) (obj && (![obj isEqual:[NSNull null]]) && (![obj isEqual:@"<null>"]) )




