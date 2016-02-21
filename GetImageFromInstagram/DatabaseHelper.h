//
//  DatabaseHelper.h
//  GetImageFromInstagram
//
//  Created by Home on 2/21/16.
//  Copyright (c) 2016 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseHelper : NSObject
@property (strong, nonatomic) NSString *tagSearch;
@property (assign, nonatomic) BOOL isCreatedTable;
+(instancetype) sharedDatabaseHelper;
-(NSString *) dataFilePath;
-(void) selectTagSearch;
-(void) insertTag;
@end
