//
//  CatalogService.h
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatalogService : NSObject

+ (instancetype)sharedInstance;

- (void)loadCatalogsWithCompletion:(void (^)(id results, NSError* error))completion;

@end
