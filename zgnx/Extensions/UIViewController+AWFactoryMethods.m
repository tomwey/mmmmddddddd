//
//  AWFactoryMethods.m
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UIViewController+AWFactoryMethods.h"

@implementation UIViewController (AWFactoryMethods)

+ (UIViewController *)viewControllerWithClass:(Class)controllerClz
{
//    NSParameterAssert([controllerClz isSubclassOfClass:]);
    return [[controllerClz alloc] init];
}

+ (UIViewController *)viewControllerWithClassName:(NSString *)controllerClassName
{
    NSParameterAssert(!!controllerClassName);
    return [self viewControllerWithClass:NSClassFromString(controllerClassName)];
}

@end
