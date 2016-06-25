//
//  UIViewController+CreateTabBarItem.m
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UIViewController+CreateTabBarItem.h"

@implementation UIViewController (CreateTabBarItem)

- (UITabBarItem *)createTabBarItemWithTitle:(NSString *)title
                                      image:(UIImage *)image
                              selectedImage:(UIImage *)selectedImage
               titleTextAttributesForNormal:(NSDictionary *)attributes
             titleTextAttributesForSelected:(NSDictionary *)selectedAttributes
{
    UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.tabBarItem = item;
    
    if ( !image ) {
        self.tabBarItem.selectedImage = nil;
        
        CGSize size = [title sizeWithAttributes:attributes];
        self.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, - ( 49 - size.height ) / 2.0 + 3 ); // tabBar高度为49
        [self.tabBarItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    
    [self.tabBarItem setTitleTextAttributes:selectedAttributes
                                   forState:UIControlStateSelected];
    
    return item;
}

@end
