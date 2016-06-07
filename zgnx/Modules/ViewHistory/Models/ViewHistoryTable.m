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
    return @"data.sqlite";
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
             @"video_file": @"TEXT",
             @"cover_image": @"TEXT",
             @"view_count": @"INTEGER",
             @"likes_count": @"INTEGER",
             @"msg_count": @"INTEGER",
             @"type": @"INTEGER",
             @"video_id": @"INTEGER",
             @"stream_id": @"TEXT",
             @"created_on": @"TEXT",
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
