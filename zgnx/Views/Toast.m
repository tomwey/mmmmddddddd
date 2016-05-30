//
//  Toast.m
//  iFunnyGif
//
//  Created by tangwei1 on 14-9-1.
//  Copyright (c) 2014年 tangwei1. All rights reserved.
//

#import "Toast.h"
#import <QuartzCore/QuartzCore.h>

@interface Toast ()

@end

@implementation Toast
{
    UILabel* _label;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:16];
        
        [self addSubview:_label];
        
        self.backgroundColor = [UIColor blackColor];
        
        CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
        CGFloat height = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) + 44;
        
        self.frame = CGRectMake(0, 0, width, height);
    }
    return self;
}

+ (Toast *)showText:(NSString *)text
{
    return [self showText:text forView:[[UIApplication sharedApplication].windows objectAtIndex:0]];
}

+ (Toast *)showText:(NSString *)text forView:(UIView *)superView
{
    Toast* t = [[Toast alloc] init];
    [superView addSubview:t];
    [superView bringSubviewToFront:t];
    
    t.backgroundColor = [UIColor blackColor];
//    t.alpha = 0.8;
    
    [t showText:text];
    
    return t;
}

- (void)showText:(NSString *)text
{
    _label.text = text;
    
    BOOL statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    CGSize size = [text sizeWithAttributes:@{ NSFontAttributeName: _label.font }];
    _label.frame = CGRectMake(0, 0, size.width, size.height);
    _label.center = CGPointMake(CGRectGetWidth(self.bounds) / 2,
                                CGRectGetHeight(self.bounds) / 2);
    
    CGRect frame = self.bounds;
    self.center = CGPointMake(CGRectGetWidth(frame) * 0.5, - CGRectGetHeight(frame) * 0.5);
    
    [UIView animateWithDuration:.3 animations:^{
        self.center = CGPointMake(CGRectGetWidth(frame) * 0.5, CGRectGetHeight(frame) * 0.5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 delay:.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.center = CGPointMake(CGRectGetWidth(frame) * 0.5, - CGRectGetHeight(frame) * 0.5);
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden];
            [self removeFromSuperview];
        }];
    }];
}

@end
