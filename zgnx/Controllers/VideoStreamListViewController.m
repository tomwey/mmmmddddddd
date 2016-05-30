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
    
    self.navBar.backgroundColor = NAV_BAR_BG_COLOR;
    self.navBar.leftItem = AWCreateImageView(@"zgly_logo.png");
    
    [self.navBar addFluidBarItem:AWCreateImageButtonWithSize(@"nav_search.png", CGSizeMake(35,35), self, @selector(gotoSearch))
                      atPosition:FluidBarItemPositionTitleRight];
    [self.navBar addFluidBarItem:AWCreateImageButtonWithSize(@"nav_history.png", CGSizeMake(35,35), self, @selector(gotoHistory))
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
