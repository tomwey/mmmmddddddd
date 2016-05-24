//
//  LiveViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "LiveViewController.h"
#import "Defines.h"

@implementation LiveViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        
        [self createTabBarItemWithTitle:@"直播"
                                  image:nil
                          selectedImage:nil
                    titleTextAttributes:@{ NSFontAttributeName : AWSystemFontWithSize(16, NO) }];
        
    }
    return self;
}

@end
