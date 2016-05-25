//
//  PagerTabStripper.h
//  BayLe
//
//  Created by tangwei1 on 15/11/20.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagerTabStripper : UIView

/** 设置标题字体, 默认为系统15号字体 */
@property (nonatomic, retain) UIFont* titleFont;

/** 设置标题文字颜色，默认为黑色 */
@property (nonatomic, retain) UIColor* titleColor;

/** 设置选中的tab的标题颜色，默认为红色 */
@property (nonatomic, retain) UIColor* selectedTitleColor;

/** 设置是否允许显示选中标识，默认为YES */
@property (nonatomic, assign) BOOL allowShowIndicator;

/** 设置选中的指示标志颜色，默认为黑色 */
@property (nonatomic, retain) UIColor* selectedIndicatorColor;

/** 选中标识的高度，默认为2 */
@property (nonatomic, assign) CGFloat selectedIndicatorSize;

/** 标题数组，数组中的元素为字符串类型 */
@property (nonatomic, copy) NSArray* titles;

/** 选中的条目索引，默认值为0 */
@property (nonatomic, assign) NSInteger selectedIndex;

/** 绑定选中事件 */
- (void)bindTarget:(id)target forAction:(SEL)action;

- (void)scrollTo:(CGFloat)dt;

@end

