//
//  VideoStreamModule.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "LiveModule.h"
#import "LiveViewController.h"

@implementation CTMediator (LiveModule)

- (UIViewController *)CTMediator_openLiveVC
{
    return [[LiveViewController alloc] init];
}

@end
