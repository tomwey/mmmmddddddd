//
//  VideoStreamModule.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "ViewHistoryModule.h"
#import "ViewHistoryListViewController.h"

@implementation CTMediator (LiveModule)

- (UIViewController *)CTMediator_openViewHistoryVCWithAuthToken:(NSString *)authToken
{
    return [[ViewHistoryListViewController alloc] initWithAuthToken:authToken];
}

@end
