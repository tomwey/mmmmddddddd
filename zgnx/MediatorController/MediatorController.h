//
//  MediatorController.h
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediatorController : NSObject

+ (instancetype)sharedInstance;

- (UIViewController *)rootViewController;

- (UIViewController *)openVC:(NSString *)controllerName withParams:(NSDictionary *)params;

@end
