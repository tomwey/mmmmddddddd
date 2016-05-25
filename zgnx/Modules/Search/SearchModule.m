//
//  VideoStreamModule.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "SearchModule.h"
#import "SearchViewController.h"

@implementation CTMediator (SearchModule)

- (UIViewController *)CTMediator_openSearchVC
{
    return [[SearchViewController alloc] init];
}

@end
