//
//  LikeService.h
//  zgnx
//
//  Created by tangwei1 on 16/6/7.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@interface LikeService : NSObject

- (void)likeByUser:(User *)user completion:(void (^)(id result, NSError *error))completion;

- (void)cancelLikeByUser:(User *)user completion:(void (^)(id result, NSError *error))completion;

@end
