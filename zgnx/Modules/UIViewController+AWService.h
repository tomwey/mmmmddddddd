//
//  UIViewController+AWService.h
//  zgnx
//
//  Created by tangwei1 on 16/5/30.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AWService <NSObject>

@end

@interface UIViewController (AWService)

/**
 注入一个服务，暂时不支持注入多个服务对象
 
 @params aServiceClass 一个需要符合AWService协议的类
 @return 返回是否注入成功
 */
- (BOOL)injectService:(Class)aServiceClass;

/** 返回当前的已经注入的服务对象 */
@property (nonatomic, strong, readonly) id <AWService> service;

@end
