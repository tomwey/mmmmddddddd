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

- (UIViewController *)CTMediator_openVideoStreamVCWithData:(id)data
{
    return [[VideoStreamDetailViewController alloc] initWithStreamData:data];
}

@end
