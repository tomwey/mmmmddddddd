//
//  TabsControl.h
//  zgnx
//
//  Created by tangwei1 on 16/5/27.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TabsPosition) {
    TabsPositionTop,
    TabsPositionLeft,
    TabsPositionBottom,
    TabsPositionRight,
};

@class TabsControl;
@protocol TabsControlDelegate;

@protocol TabsControlDataSource <NSObject>

- (NSUInteger)numberOfTabs:(TabsControl *)tabsControl;

- (NSString *)tabs:(TabsControl *)tabsControl titleForItemAtIndex:(NSInteger)index;

- (UIView *)tabs:(TabsControl *)tabsControl viewForItemAtIndex:(NSInteger)index;

@end

@interface TabsControl : UIView

- (instancetype)initWithFrame:(CGRect)frame tabsPosition:(TabsPosition)position;

/** 工具条在组件中的位置，默认为TabsPositionTop */
@property (nonatomic, assign) TabsPosition tabsPosition;

@property (nonatomic, assign) id <TabsControlDataSource> dataSource;
@property (nonatomic, assign) id <TabsControlDelegate>   delegate;

- (UIView *)dequeueReusableViewForIndex:(NSInteger)index;

- (void)reloadData;

@end

@protocol TabsControlDelegate <NSObject>

@optional
- (void)tabs:(TabsControl*)tabsControl didSelectItemAtIndex:(NSInteger)index;

- (UIColor *)tabs:(TabsControl *)tabsControl colorForItemTitleAtIndex:(NSInteger)index;
- (UIColor *)tabs:(TabsControl *)tabsControl selectedColorForItemTitleAtIndex:(NSInteger)index;


@end
