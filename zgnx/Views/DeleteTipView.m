//
//  DeleteTipView.m
//  zgnx
//
//  Created by tangwei1 on 16/6/29.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "DeleteTipView.h"
#import "Defines.h"

@interface DeleteTipView ()

@property (nonatomic, strong) UIView *maskView;

@end

@implementation DeleteTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
//        self.frame = [[UIScreen mainScreen] bounds];
        
        self.maskView = [[UIView alloc] initWithFrame:self.bounds];
        self.maskView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.maskView];
        self.maskView.alpha = 0.6;
        
        UILabel *label = AWCreateLabel(CGRectMake(0, 0,
                                                  self.width * 0.8,
                                                  self.width * 0.382),
                                       @"长按每个视频，可以删除",
                                       NSTextAlignmentCenter,
                                       nil,
                                       nil);
        label.center = CGPointMake(self.width / 2, self.height / 2);
        [self addSubview:label];
        
        label.backgroundColor = [UIColor whiteColor];
        
        label.layer.cornerRadius = 4;
        label.clipsToBounds = YES;
        
        label.numberOfLines = 0;
        
        // 删除按钮
        UIButton *delBtn = AWCreateImageButton(@"his_delete.png", self, @selector(deleteMe));
        [self addSubview:delBtn];
        delBtn.center = CGPointMake(label.right - 5,
                                    label.top + 5);
    }
    return self;
}

- (void)deleteMe
{
    [self removeFromSuperview];
}

+ (void)showTip:(NSString *)identifier inView:(UIView *)superView frame:(CGRect)frame
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@.hasShown", identifier];
    if ( [ud boolForKey:key] ) {
        return;
    }
    
    [ud setBool:YES forKey:key];
    [ud synchronize];
    
    DeleteTipView *tipView = [[DeleteTipView alloc] initWithFrame:frame];
    [superView addSubview:tipView];
    [superView bringSubviewToFront:tipView];
}

@end
