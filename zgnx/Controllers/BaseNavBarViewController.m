//
//  BaseNavBarViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/27.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "BaseNavBarViewController.h"
#import "Defines.h"

@implementation BaseNavBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.backgroundColor = NAV_BAR_BG_COLOR;
    self.navBar.leftItem = AWCreateImageButton(@"btn_back.png",
                                               self,
                                               @selector(back));
    
    self.navBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: AWSystemFontWithSize(18, NO) };
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
