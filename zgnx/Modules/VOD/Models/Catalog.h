//
//  Catalog.h
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Catalog : NSObject

+ (void)loadCatalogsWithCompletion:( void (^)(NSArray* result, NSError* error) )completion;

@end
