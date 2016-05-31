//
//  ViewHistoryTable.m
//  zgnx
//
//  Created by tangwei1 on 16/5/31.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "ViewHistoryTable.h"
#import "ViewHistory.h"

@implementation ViewHistoryTable

- (NSString *)databaseName
{
    return @"VHDB.sqlite";
}

- (NSString *)tableName
{
    return @"ViewHistory";
}

- (NSDictionary *)columnInfo
{
    return @{
             @"vid": @"INTEGER PRIMARY KEY AUTOINCREMENT",
             @"title": @"TEXT",
             @"videoFile": @"TEXT",
             @"coverImage": @"TEXT",
             @"viewCount": @"INTEGER",
             @"likesCount": @"INTEGER",
             @"msgCount": @"INTEGER",
             @"type": @"INTEGER",
             @"streamId": @"TEXT",
             @"createdOn": @"TEXT",
             @"currentPlaybackTime": @"INTEGER"
             };
}

- (Class)recordClass
{
    return [ViewHistory class];
}

- (NSString *)primaryKeyName
{
    return @"vid";
}

@end
