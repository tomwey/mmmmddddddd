//
//  LoadDataService.h
//  zgnx
//
//  Created by tangwei1 on 16/6/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadDataService : NSObject

- (void)GET:(NSString *)api
     params:(NSDictionary<NSString*, id> *)params
 completion:(void (^)(id result, NSError* error))completion;

- (void)POST:(NSString *)api
     params:(NSDictionary<NSString*, id> *)params
 completion:(void (^)(id result, NSError* error))completion;

@end
