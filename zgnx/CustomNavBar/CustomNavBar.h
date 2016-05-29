//
//  CustomNavBar.h
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FluidBarItemPosition) {
    FluidBarItemPositionTitleLeft = 0, // 标题左边
    FluidBarItemPositionTitleRight = 1, // 标题右边
};

@interface CustomNavBar : UIView

@property (nonatomic, strong, nullable) UIImage* backgroundImage;

/**
 ! 设置左右固定位置的item
 */
@property (nonatomic, strong, nullable) UIView* leftItem;
@property (nonatomic, strong, nullable) UIView* rightItem;

/**
 ! 设置标题
 */
@property (nonatomic, copy, nullable)   NSString* title;

/**
 ! 设置标题文字属性
 
 @see NSMutableAttributes.h
 */
@property (nonatomic, copy, nullable)   NSDictionary<NSString*, id>* titleTextAttributes;

/**
 ! 设置标题视图
 */
@property (nonatomic, strong, nullable) UIView*   titleView;

/**
 ! 添加导航条非固定item
 
 如果导航条有固定的leftItem，那么被添加的靠左item会依次排在leftItem的右边，
 如果导航条没有固定的leftItem, 那么被添加的item会从leftItem的位置开始，依次添加。
 在导航条右边添加item同理。
 */
- (void)addFluidBarItem:(UIView *)item atPosition:(FluidBarItemPosition)position;

@end

/// 未考虑屏幕方向
@interface UIViewController (CustomNavBar)

/**
 ! 返回一个该页面的导航条，并添加到页面顶部
 
 注意：请在已经有根视图self.view的前提下调用，否则可能会引起崩溃。
 另：如果调用此属性，请使用self.contentView存放所有该页面的子视图，不包括navBar以及navBar的子视图
 */
@property (nonatomic, strong, readonly) CustomNavBar* navBar;

/**
 ! 返回一个存放子视图的容器视图
 
 如果使用了CustomNavBar控件，那么会返回一个新的自定义的容器视图，
 并且容器视图的frame为：CGRectMake(0, navBar的高度, 全屏宽，全屏高 - navBar的高度)；
 否则返回默认的根视图self.view
 */
@property (nonatomic, strong, readonly) UIView* contentView;

@end

NS_ASSUME_NONNULL_END
