//
//  LiveService.h
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveService : NSObject

+ (instancetype)sharedInstance;

- (void)loadLivingVideos:(void (^)(NSArray* result, NSError* error))completion;

- (void)loadHotLivedVideosForPage:(NSInteger)pageNo
                       completion:(void (^)(NSArray* results, NSError* error))completion;

@end
