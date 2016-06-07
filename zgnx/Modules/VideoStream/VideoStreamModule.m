//
//  VideoStreamModule.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VideoStreamModule.h"
#import "VideoStreamDetailViewController.h"

@implementation CTMediator (VideoStreamModule)

- (UIViewController *)CTMediator_openVideoStreamVCWithData:(id)data fromType:(NSInteger)type
{
    UIViewController* vc = [[VideoStreamDetailViewController alloc] initWithStreamData:data fromType:type];
//    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    nav.navigationBarHidden = YES;
    return vc;
}

@end

