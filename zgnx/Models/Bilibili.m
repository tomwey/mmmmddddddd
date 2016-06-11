//
//  Bilibili.m
//  zgnx
//
//  Created by tomwey on 6/11/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "Bilibili.h"

@implementation Bilibili

- (instancetype)initWithDictionary:(NSDictionary *)jsonResult
{
    if ( self = [super init] ) {
        self.bid = jsonResult[@"id"];
        self.content = jsonResult[@"content"];
        self.streamId = jsonResult[@"stream_id"];
        self.nickname = jsonResult[@"author"][@"nickname"] ?: @"游客";
        self.avatarUrl = jsonResult[@"author"][@"avatar"] ?: @"";
        self.sentAt = [jsonResult[@"sent_at"] description];
    }
    return self;
}

@end
