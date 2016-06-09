//
//  StreamTable.m
//  zgnx
//
//  Created by tomwey on 6/9/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "StreamTable.h"
#import "Stream.h"

@implementation StreamTable

- (NSString *)databaseName
{
    return @"zgny.sqlite";
}

- (NSString *)tableName
{
    return @"streams";
}

- (NSDictionary *)columnInfo
{
    return @{
             @"identifier": @"INTEGER PRIMARY KEY AUTOINCREMENT",
             @"id_": @"INTEGER",
             @"title": @"TEXT",
             @"body": @"TEXT",
             @"cover_image": @"TEXT",
             @"video_file": @"TEXT",
             @"type": @"INTEGER",
             @"view_count": @"INTEGER",
             @"likes_count": @"INTEGER",
             @"msg_count": @"INTEGER",
             @"stream_id": @"TEXT",
             @"created_on": @"TEXT",
             @"liked": @"INTEGER",
             @"rtmp_url": @"TEXT",
             @"hls_url": @"TEXT",
             @"currentPlaybackTime": @"TEXT",
             };
}

- (Class)recordClass
{
    return [Stream class];
}

- (NSString *)primaryKeyName
{
    return @"identifier";
}

@end
