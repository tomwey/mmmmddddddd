//
//  Stream.m
//  zgnx
//
//  Created by tomwey on 6/9/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "Stream.h"

@implementation Stream

- (instancetype)initWithDictionary:(NSDictionary *)jsonResult
{
    if ( self = [super init] ) {
        self.id_ = jsonResult[@"id"];
        self.title = jsonResult[@"title"];
        self.body = jsonResult[@"body"];
        self.cover_image = jsonResult[@"cover_image"];
        self.video_file = jsonResult[@"video_file"];
        self.type = jsonResult[@"type"];
        self.view_count = jsonResult[@"view_count"];
        self.likes_count = jsonResult[@"likes_count"];
        self.msg_count = jsonResult[@"msg_count"];
        self.stream_id = jsonResult[@"stream_id"];
        self.created_on = jsonResult[@"created_on"];
        self.liked = jsonResult[@"liked"];
        self.favorited = jsonResult[@"favorited"];
        self.rtmp_url = jsonResult[@"rtmp_url"];
        self.hls_url = jsonResult[@"hls_url"];
    }
    return self;
}

@end
