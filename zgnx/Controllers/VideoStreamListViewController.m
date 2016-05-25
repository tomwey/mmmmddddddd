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
    
    self.navBar.backgroundColor = AWColorFromRGB(40, 182, 238);
    self.navBar.leftItem = AWCreateLabel(CGRectMake(0, 0, 100, 37),
                                         @"中国旅游",
                                         NSTextAlignmentLeft,
                                         AWSystemFontWithSize(16, YES),
                                         [UIColor whiteColor]);
    
    [self.navBar addFluidBarItem:AWCreateTextButton(CGRectMake(0, 0, 44, 44),
                                                    @"搜索",
                                                    [UIColor whiteColor],
                                                    self,
                                                    @selector(gotoSearch))
                      atPosition:FluidBarItemPositionTitleRight];
    [self.navBar addFluidBarItem:AWCreateTextButton(CGRectMake(0, 0, 44, 44),
                                                    @"历史",
                                                    [UIColor whiteColor],
                                                    self,
                                                    @selector(gotoHistory))
                      atPosition:FluidBarItemPositionTitleRight];
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
