//
//  Toast.h
//  iFunnyGif
//
//  Created by tangwei1 on 14-9-1.
//  Copyright (c) 2014年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleToast : UIView

// 显示在window中
+ (void)showText:(NSString *)text;
+ (void)showText:(NSString *)text forView:(UIView *)superView;

@end
