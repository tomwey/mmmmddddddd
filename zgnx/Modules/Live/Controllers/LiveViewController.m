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
                                  image:[UIImage imageNamed:@"tab_live_n.png"]
                          selectedImage:[UIImage imageNamed:@"tab_live_s.png"]
           titleTextAttributesForNormal:nil
         titleTextAttributesForSelected:@{ NSForegroundColorAttributeName: AWColorFromRGB(20, 118, 255) }];
        
    }
    return self;
}

@end
