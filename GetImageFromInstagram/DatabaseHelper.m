//
//  DatabaseHelper.m
//  GetImageFromInstagram
//
//  Created by Home on 2/21/16.
//  Copyright (c) 2016 Home. All rights reserved.
//

#import "DatabaseHelper.h"
#import <sqlite3.h>

@implementation DatabaseHelper

+(instancetype) sharedDatabaseHelper
{
    static DatabaseHelper *_sharedDatabaseHelper = nil;
    static dispatch_once_t one;
    dispatch_once(&one, ^{
        _sharedDatabaseHelper = [[DatabaseHelper alloc] init];
    });
    
    return  _sharedDatabaseHelper;
}

-(instancetype)init
{
    if(self = [super init])
    {
        if(!self.isCreatedTable)
        {
            [self createTable];
        }
    }
    return  self;
}
-(NSString *) dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingString:@"data.sqlite"];
}

-(void) createTable
{
    if(!self.isCreatedTable)
    {
        sqlite3 *database;
        if (sqlite3_open([[self dataFilePath] UTF8String], &database)!= SQLITE_OK) {
            sqlite3_close(database);
            NSAssert(0, @"Failed to open database");
        }
        
        // Useful C trivia: If two inline strings are separated by nothing
        // but whitespace (including line breaks), they are concatenated into
        // a single string:
        NSString *createSQL = @"CREATE TABLE IF NOT EXISTS FIELDS (ROW INTEGER PRIMARY KEY, FIELD_DATA TEXT);";
        char *errorMsg;
        if (sqlite3_exec (database, [createSQL UTF8String],NULL, NULL, &errorMsg) != SQLITE_OK) {
            sqlite3_close(database);
            NSAssert(0, @"Error creating table: %s", errorMsg);
        }
        else
        {
            self.isCreatedTable = YES;
        }
    }
    else{
        NSLog(@"Just created table");
    }
    
}

-(void) selectTagSearch
{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)!= SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *query = @"SELECT ROW, FIELD_DATA FROM FIELDS ORDER BY ROW";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *rowData = (char *)sqlite3_column_text(statement, 1);
            if(rowData != NULL){
                self.tagSearch = [[NSString alloc] initWithUTF8String:rowData];
            }
            
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}

- (void)insertTag
{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    // Once again, inline string concatenation to the rescue:
    char *update = "INSERT OR REPLACE INTO FIELDS (ROW, FIELD_DATA) VALUES (?, ?);";
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)== SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, 0);
        sqlite3_bind_text(stmt, 2, [self.tagSearch UTF8String], -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert(0, @"Error updating table: %s", errorMsg);
    }
    sqlite3_finalize(stmt);
    sqlite3_close(database);
}

@end
