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

@property (nonatomic, strong) UIView* inLeftItem;
@property (nonatomic, strong) UIView* inRightItem;
@property (nonatomic, strong) UIView* inTitleView;
@property (nonatomic, strong) UILabel* inTitleLabel;

@property (nonatomic, strong) NSMutableArray* leftFluidItems;
@property (nonatomic, strong) NSMutableArray* rightFluidItems;

@end

@implementation CustomNavBar

static CGFloat const kLeftItemLeftOffset   = 15.0;
static CGFloat const kRightItemRightOffset = kLeftItemLeftOffset;
static CGFloat const kFluidItemSpacing     = 10.0;

@dynamic backgroundImage, leftItem, rightItem, title, titleView;

#pragma mark -
#pragma mark Lifecycle methods
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
    self.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 44 + /*[self statusBarHeight]*/ 20);
    
    self.backgroundView = [[UIImageView alloc] init];
    self.backgroundView.frame = self.bounds;
    [self addSubview:self.backgroundView];
    self.backgroundView.userInteractionEnabled = YES;
}

- (void)dealloc
{
    self.backgroundView = nil;
    _inLeftItem = nil;
    _inRightItem = nil;
    _inTitleView = nil;
    self.inTitleLabel = nil;
    
    self.leftFluidItems = nil;
    self.rightFluidItems = nil;
}

#pragma mark -
#pragma mark Layout method
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ( self.leftItem ) {
        self.inLeftItem.center = CGPointMake(kLeftItemLeftOffset + CGRectGetWidth(self.inLeftItem.bounds) / 2,
                                             CGRectGetHeight(self.bounds) / 2 + [self statusBarHeight]/2);
    }
    
    if ( self.rightItem ) {
        self.inRightItem.center = CGPointMake(CGRectGetWidth(self.bounds) - kRightItemRightOffset - CGRectGetWidth(self.inLeftItem.bounds) / 2,
                                              CGRectGetHeight(self.bounds) / 2 + [self statusBarHeight]/2);
    }
    
    if ( self.inTitleLabel ) {
        self.inTitleLabel.frame  = CGRectMake(0, 0, CGRectGetWidth(self.bounds) * 0.618, 40);
        self.inTitleLabel.center = CGPointMake(CGRectGetWidth(self.bounds) / 2,
                                               CGRectGetHeight(self.bounds) / 2 + [self statusBarHeight]/2);
    }
    
    if ( self.inTitleView ) {
        self.inTitleView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2,
                                              CGRectGetHeight(self.bounds) / 2 + [self statusBarHeight]/2);
    }
    
    [self layoutFluidItems];
}

#pragma mark - 
#pragma mark Public Methods
- (void)addFluidBarItem:(UIView *)item atPosition:(FluidBarItemPosition)position
{
    switch (position) {
        case FluidBarItemPositionTitleLeft:
        {
            if ( !self.leftFluidItems ) {
                self.leftFluidItems = [NSMutableArray array];
            }
            
            if ( ![self.leftFluidItems containsObject:item] ) {
                [self.leftFluidItems addObject:item];
                
                [self.backgroundView addSubview:item];
            }
        }
            break;
        case FluidBarItemPositionTitleRight:
        {
            if ( !self.rightFluidItems ) {
                self.rightFluidItems = [NSMutableArray array];
            }
            
            if ( ![self.rightFluidItems containsObject:item] ) {
                [self.rightFluidItems addObject:item];
                
                [self.backgroundView addSubview:item];
            }
        }
            break;
            
        default:
            break;
    }
    
    [self layoutFluidItems];
}

- (void)setTitleTextAttributes:(NSDictionary<NSString *,id> *)titleAttributes
{
    _titleTextAttributes = titleAttributes;
    if ( self.inTitleLabel && [titleAttributes count] > 0 ) {
//        NSString* text = [NSString stringWithString:self.title];
//        self.inTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:titleAttributes];
//        self.inTitleLabel.text = nil;
//        text = nil;
        if ( titleAttributes[NSFontAttributeName] ) {
            self.inTitleLabel.font = titleAttributes[NSFontAttributeName];
        }
        
        if ( titleAttributes[NSForegroundColorAttributeName] ) {
           self.inTitleLabel.textColor = titleAttributes[NSForegroundColorAttributeName]; 
        }
        
    }
}

#pragma mark -
#pragma mark Override Setters and Getters
///---------------------------- 设置左导航条目 -----------------------------------
- (void)setLeftItem:(UIView *)leftItem
{
    if ( !leftItem ) {
        [self.inLeftItem removeFromSuperview];
    } else {
        if ( leftItem != self.inLeftItem ) {
            if ( self.inLeftItem.superview ) {
                [self.inLeftItem removeFromSuperview];
            }
            
            self.inLeftItem = leftItem;
            [self.backgroundView addSubview:self.inLeftItem];
        }
    }
    
    [self layoutFluidItems];
}

- (UIView *)leftItem { return self.inLeftItem; }

///---------------------------- 设置右导航条目 ------------------------------------
- (void)setRightItem:(UIView *)rightItem
{
    if ( !rightItem ) {
        [self.inRightItem removeFromSuperview];
    } else {
        if ( rightItem != self.inRightItem ) {
            if ( self.inRightItem.superview ) {
                [self.inRightItem removeFromSuperview];
            }
            
            self.inRightItem = rightItem;
            [self.backgroundView addSubview:self.inRightItem];
        }
    }
    
    [self layoutFluidItems];
}

- (UIView *)rightItem { return self.inRightItem; }

///---------------------------- 设置标题 ------------------------------------
- (void)setTitle:(NSString *)title
{
    if ( !title ) {
        [self.inTitleLabel removeFromSuperview];
        self.inTitleLabel = nil;
    } else {
        if ( !self.inTitleLabel ) {
            self.inTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                      CGRectGetWidth(self.bounds) * 0.618,
                                                                      44)];
            
            self.inTitleLabel.backgroundColor = [UIColor clearColor];
            self.inTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.backgroundView addSubview:self.inTitleLabel];
        }
        self.inTitleLabel.text = title;
        if ( self.titleTextAttributes ) {
            if ( self.titleTextAttributes[NSFontAttributeName] ) {
                self.inTitleLabel.font = self.titleTextAttributes[NSFontAttributeName];
            }
            
            if ( self.titleTextAttributes[NSForegroundColorAttributeName] ) {
                self.inTitleLabel.textColor = self.titleTextAttributes[NSForegroundColorAttributeName];
            }
        }
    }
}

- (NSString *)title { return self.inTitleLabel.text ?: self.inTitleLabel.attributedText.string; }

///---------------------------- 设置自定义标题视图 ------------------------------------
- (void)setTitleView:(UIView *)titleView
{
    if ( !titleView ) {
        [self.inTitleView removeFromSuperview];
        self.inTitleView = nil;
    } else {
        if ( self.inTitleView == titleView ) {
            return;
        }
        
        if ( self.inTitleView.superview ) {
            [self.inTitleView removeFromSuperview];
        }
        
        self.inTitleView = titleView;
        [self.backgroundView addSubview:self.inTitleView];
    }
}

- (UIView *)titleView { return self.inTitleView; }

///---------------------------- 设置背景图片和背景颜色 ------------------------------------
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

#pragma mark -
#pragma mark Private Methods
- (CGFloat)statusBarHeight
{
    return CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
}

- (void)layoutFluidItems
{
    CGFloat lastMaxX = kLeftItemLeftOffset + CGRectGetWidth(self.leftItem.frame);
    if ( lastMaxX > kLeftItemLeftOffset ) {
        lastMaxX += kFluidItemSpacing;
    }
    
    for (UIView* item in self.leftFluidItems) {
        item.center = CGPointMake(lastMaxX + CGRectGetWidth(item.frame) / 2,
                                  CGRectGetHeight(self.bounds) / 2 + [self statusBarHeight]/2);
        lastMaxX = CGRectGetMaxX(item.frame) + kFluidItemSpacing;
    }
    
    // 设置右边的流式item坐标
    lastMaxX = CGRectGetWidth(self.bounds) - kRightItemRightOffset - CGRectGetWidth(self.rightItem.frame);
    if ( self.rightItem ) {
        lastMaxX -= kFluidItemSpacing;
    }
    NSUInteger count = self.rightFluidItems.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        UIView* item = self.rightFluidItems[i];
        item.center = CGPointMake(lastMaxX - CGRectGetWidth(item.frame) / 2,
                                  CGRectGetHeight(self.bounds) / 2 + [self statusBarHeight]/2);
        lastMaxX = CGRectGetMinX(item.frame) - kFluidItemSpacing;
    }
}

@end

#import <objc/runtime.h>
@implementation UIViewController (CustomNavBar)

static CGFloat const kCustomNavBarTag = 1011013;
static CGFloat const kContentViewTag  = 1011014;

- (CustomNavBar *)navBar
{
    CustomNavBar* navBar = (CustomNavBar* )[self.view viewWithTag:kCustomNavBarTag];
    if ( !navBar ) {
        self.navigationController.navigationBarHidden = YES;
        
        navBar = [[CustomNavBar alloc] init];
        
        // 设置默认属性
        navBar.backgroundColor = [UIColor whiteColor];
        
//        navBar.layer.shadowColor = [[UIColor colorWithRed:51 / 255.0
//                                                    green:51 / 255.0
//                                                     blue:51 / 255.0
//                                                    alpha:1.0] CGColor];
//        navBar.layer.shadowOffset = CGSizeMake(0, 0.5);
//        navBar.layer.shadowOpacity = 0.6;
//        navBar.layer.shadowRadius = 0.5;
        
        navBar.tag = kCustomNavBarTag;
        
        [self.view addSubview:navBar];
        
        // 创建一个contentView
        UIView* contentView = [[UIView alloc] initWithFrame:
                               CGRectMake(0,
                                          CGRectGetHeight(navBar.frame),
                                          CGRectGetWidth(self.view.bounds),
                                          CGRectGetHeight(self.view.bounds) - CGRectGetHeight(navBar.frame))];
        contentView.tag = kContentViewTag;
        [self.view addSubview:contentView];
    }
    
    return navBar;
}

- (UIView *)contentView
{
    return [self.view viewWithTag:kContentViewTag] ?: self.view;
}

//- (void)setTitle:(NSString *)title
//{
//    self.navBar.title = title;
//}
//
//- (NSString *)title { return self.navBar.title; }

@end
