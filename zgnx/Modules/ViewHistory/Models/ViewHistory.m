//
//  ViewHistory.m
//  zgnx
//
//  Created by tangwei1 on 16/5/31.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "ViewHistory.h"

@implementation ViewHistory

- (NSDictionary *)dictionaryRepresentationWithTable:(CTPersistanceTable<CTPersistanceTableProtocol> *)table
{
    return @{
             @"id" : self.video_id,
             @"title": self.title,
             @"video_file": self.video_file,
             @"cover_image": self.cover_image,
             @"view_count": self.view_count,
             @"likes_count": self.likes_count,
             @"type": self.type,
             @"msg_count": self.msg_count,
             @"stream_id": self.stream_id,
             @"created_on": self.created_on,
             @"currentPlaybackTime": self.currentPlaybackTime ?: @(0),
             };
}

@end
