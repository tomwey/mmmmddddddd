//
//  CustomNavBar.m
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "CustomNavBar.h"

@interface CustomNavBar ()

@property (nonatomic, strong) UIImageView* backgroundView;

@end

@implementation CustomNavBar

@dynamic backgroundImage;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder:aDecoder] ) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.bounds = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 64);
    
    self.backgroundView = [[UIImageView alloc] init];
    self.backgroundView.frame = self.bounds;
    [self addSubview:self.backgroundView];
    self.backgroundView.userInteractionEnabled = YES;
}

- (void)dealloc
{
    self.backgroundView = nil;
}

#pragma mark -
#pragma mark Override Setters and Getters

- (void)setLeftItem:(UIView *)leftItem
{
    [self.backgroundView viewWithTag:1001];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    self.backgroundView.image = backgroundImage;
}

- (UIImage *)backgroundImage { return self.backgroundView.image; }

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.backgroundView.image = nil;
    self.backgroundView.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor { return self.backgroundView.backgroundColor; }

@end
