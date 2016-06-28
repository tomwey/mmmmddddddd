//
//  PlayStatManager.h
//  zgnx
//
//  Created by tangwei1 on 16/6/28.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stream;
@interface PlayStatManager : NSObject

+ (instancetype)sharedInstance;

- (void)playStat:(Stream *)aStream;

- (void)cancelPlayStat:(Stream *)aStream;

@end
