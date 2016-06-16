//
//  VideoStreamModule.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "SearchModule.h"
#import "SearchViewController.h"
#import "SearchResultsViewController.h"

@implementation CTMediator (SearchModule)

- (UIViewController *)CTMediator_openSearchVCWithVideoType:(NSUInteger)vType
{
    SearchViewController *svc = [[SearchViewController alloc] init];
    svc.videoType = vType;
    return svc;
}

- (UIViewController *)CTMediator_openSearchResultsVCWithParams:(NSDictionary *)params
{
    return [[SearchResultsViewController alloc] initWithKeyword:params[@"keyword"] videoType:[params[@"type"] integerValue]];
}

@end
