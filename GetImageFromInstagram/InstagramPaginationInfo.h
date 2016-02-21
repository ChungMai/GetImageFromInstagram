//
//  InstagramPaginationInfo.h
//  GetImageFromInstagram
//
//  Created by Home on 12/13/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramPaginationInfo : NSObject <NSCopying, NSSecureCoding, NSObject>

/**
 *  URL to receive next set of paginated items.
 */
@property (readonly) NSURL* nextURL;

/**
 *  Offset from which the next paginated Media is to be received.
 */
@property (readonly) NSString *nextMaxId;

/**
 *  Class of Objects which are being paginated.
 */
@property (readonly) Class type;

/**
 *  Initializes a new InstagramPaginationInfo object.
 *
 *  @param info Received JSON dictionary.
 *  @param type Class of Objects which are being paginated.
 */
- (instancetype)initWithInfo:(NSDictionary *)info andObjectType:(Class)type;

/**
 *  Comparing InstagramPaginationInfo objects.
 *  @param paginationInfo   An InstagramPaginationInfo object.
 *  @return                 YES is nextURLs match. Else NO.
 */
- (BOOL)isEqualToPaginationInfo:(InstagramPaginationInfo *)paginationInfo;


@end
