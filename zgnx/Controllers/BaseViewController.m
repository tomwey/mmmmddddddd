//
//  BaseViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "BaseViewController.h"
#import "Defines.h"

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navBar.leftItem = AWCreateTextButton(CGRectMake(0, 0, 44, 44),
                                              @"返回",
                                              [UIColor redColor],
                                              self,
                                              @selector(back));
}

- (void)back
{
    if ( self.navigationController ) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
