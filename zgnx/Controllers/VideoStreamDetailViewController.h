//
//  VideoStreamDetailViewController.h
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VideoFromType) {
    VideoFromTypeDefault = 0,
    VideoFromTypeHistory = 1,
    VideoFromTypeLike    = 2,
};

@class Stream;
@interface VideoStreamDetailViewController : UIViewController

//- (instancetype)initWithStreamData:(id)streamData fromType:(VideoFromType)fromType;

- (instancetype)initWithStream:(Stream *)aStream;

@end
