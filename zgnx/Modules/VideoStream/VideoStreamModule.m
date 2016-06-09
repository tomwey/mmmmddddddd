//
//  VideoStreamModule.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VideoStreamModule.h"
#import "VideoStreamDetailViewController.h"
#import "Stream.h"

@implementation CTMediator (VideoStreamModule)

- (UIViewController *)CTMediator_openVideoStreamVCWithStream:(Stream *)aStream
{
    UIViewController* vc = [[VideoStreamDetailViewController alloc] initWithStream:aStream];
//    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    nav.navigationBarHidden = YES;
    return vc;
}

@end

