//
//  InstagramEngine.h
//  GetImageFromInstagram
//
//  Created by Home on 12/10/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstagramKitConstants.h"
#import "InstagramMedia.h"

@interface InstagramEngine : NSObject
/*!
 @abstract Gets the singleton instance.
 */
+ (instancetype)sharedEngine;

/**
 *  Client Id of your App, as registered with Instagram.
 */
@property (nonatomic, copy) NSString *appClientID;

/**
 *  Redirect URL of your App, as registered with Instagram.
 */
@property (nonatomic, copy) NSString *appRedirectURL;

/**
 *  The oauth token stored in the account store credential, if available.
 *  If not empty, this implies user has granted access.
 */
@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, copy) NSString *currentTagSearch;


/**
 *  A convenience method to generate an authorization URL with Basic permissions
 *  to direct user to Instagram's login screen.
 *
 *  @return URL to direct user to Instagram's login screen.
 */
- (NSURL *)authorizationURL;


/**
 *  A convenience method to extract and save the access code from an URL received in
 *  UIWebView's delegate method - webView: shouldStartLoadWithRequest: navigationType:
 *  @param url   URL from the request object.
 *  @param error Error in extracting token, if any.
 *
 *  @return YES if valid token extracted and saved, otherwise NO.
 */
- (BOOL)receivedValidAccessTokenFromURL:(NSURL *)url
                                  error:(NSError *__autoreleasing *)error;

- (BOOL)isSessionValid;

- (void)logout;

- (void)getPopularMediaWithSuccess:(InstagramMediaBlock)success failure:(InstagramFailureBlock)failure;

/**
 *  Get the authenticated user's feed.
 *
 *  @param count    Count of objects to fetch.
 *  @param maxId    The nextMaxId from the previously obtained PaginationInfo object.
 *  @param success  Provides an array of Media objects and Pagination info.
 *  @param failure  Provides an error and a server status code.
 */
- (void)getSelfFeedWithCount:(NSInteger)count
                       maxId:(NSString *)maxId
                     success:(InstagramMediaBlock)success
                     failure:(InstagramFailureBlock)failure;

@end
