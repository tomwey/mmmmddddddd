//
//  VideoStreamListViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VideoStreamListViewController.h"
#import "Defines.h"

@implementation VideoStreamListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navBar.backgroundColor = AWColorFromRGB(224, 224, 224);
    self.navBar.leftItem = AWCreateLabel(CGRectMake(0, 0, 100, 37),
                                         @"中国旅游",
                                         NSTextAlignmentLeft,
                                         AWSystemFontWithSize(16, YES),
                                         [UIColor blackColor]);
    
    [self.navBar addFluidBarItem:AWCreateTextButton(CGRectMake(0, 0, 44, 44),
                                                    @"搜索",
                                                    [UIColor redColor],
                                                    self,
                                                    @selector(gotoSearch))
                      atPosition:FluidBarItemPositionTitleRight];
    [self.navBar addFluidBarItem:AWCreateTextButton(CGRectMake(0, 0, 44, 44),
                                                    @"历史",
                                                    [UIColor redColor],
                                                    self,
                                                    @selector(gotoHistory))
                      atPosition:FluidBarItemPositionTitleRight];
    
    [self.contentView addSubview:AWCreateLabel(CGRectMake(15, 10, 100, 30),
                                               @"test",
                                               0,
                                               nil,
                                               nil)];
}

- (void)gotoSearch
{
    UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openSearchVC];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)gotoHistory
{
    UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openViewHistoryVCWithAuthToken:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
