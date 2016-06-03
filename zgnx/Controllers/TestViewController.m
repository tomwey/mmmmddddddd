//
//  TestViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/6/3.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "TestViewController.h"
#import "Defines.h"
#import "VideoStreamDetailViewController.h"

@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton* btn = AWCreateImageButton(nil, self, @selector(click));
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(50, 50, 100, 40);
}

- (void)click
{
    VideoStreamDetailViewController* vsdvc = [[VideoStreamDetailViewController alloc] init];
    [self presentViewController:vsdvc animated:YES completion:nil];
}

@end
