//
//  Stream.h
//  zgnx
//
//  Created by tomwey on 6/9/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CTPersistance/CTPersistance.h>
#import "User.h"

typedef NS_ENUM(NSInteger, StreamFromType) {
    StreamFromTypeDefault  = 1,
    StreamFromTypeHistory  = 2,
    StreamFromTypeLike     = 3,
    StreamFromTypeUploaded = 4,
};

@interface Stream : CTPersistanceRecord <CTPersistanceRecordProtocol>

@property (nonatomic, copy) NSNumber *identifier;
@property (nonatomic, copy) NSNumber *id_;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *cover_image;
@property (nonatomic, copy) NSString *video_file;
@property (nonatomic, copy) NSNumber *type;
@property (nonatomic, copy) NSNumber *view_count;
@property (nonatomic, copy) NSNumber *likes_count;
@property (nonatomic, copy) NSNumber *msg_count;
@property (nonatomic, copy) NSString *stream_id;
@property (nonatomic, copy) NSString *created_on;
@property (nonatomic, copy) NSNumber *liked;
@property (nonatomic, copy) NSNumber *favorited;
@property (nonatomic, copy) NSNumber *approved;

@property (nonatomic, copy) NSString *rtmp_url;
@property (nonatomic, copy) NSString *hls_url;

@property (nonatomic, copy) NSString *currentPlaybackTime;

@property (nonatomic, assign) NSInteger fromType;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) User *user;

- (instancetype)initWithDictionary:(NSDictionary *)jsonResult;

@end
