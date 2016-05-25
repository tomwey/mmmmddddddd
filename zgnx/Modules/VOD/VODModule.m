//
//  VODModule.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VODModule.h"
#import "VODListViewController.h"

@implementation CTMediator (VODModule)

- (UIViewController *)CTMediator_openVODVC
{
    return [[VODListViewController alloc] init];
}

@end
