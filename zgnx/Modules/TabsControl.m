//
//  TabsControl.m
//  zgnx
//
//  Created by tangwei1 on 16/5/27.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "TabsControl.h"

@interface TabsControl ()

@property (nonatomic, strong) UIScrollView* tabsContainer;
@property (nonatomic, assign, readwrite) NSInteger selectedIndex;

@property (nonatomic, weak) UILabel* lastLabel;

@property (nonatomic, strong) NSMutableDictionary* reusableViews;

@end

@implementation TabsControl

- (instancetype)initWithFrame:(CGRect)frame tabsPosition:(TabsPosition)position
{
    if ( self = [super initWithFrame:frame] ) {
        self.tabsPosition = position;
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame tabsPosition:TabsPositionTop];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder:aDecoder] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.tabsContainer = [[UIScrollView alloc] init];
    self.tabsContainer.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.tabsContainer];
    
    self.reusableViews = [NSMutableDictionary dictionary];
}

- (void)setDataSource:(id<TabsControlDataSource>)dataSource
{
    _dataSource = dataSource;
    
    if ( dataSource ) {
        [self reloadData];
    } else {
        
    }
}

- (void)reloadData
{
    NSUInteger count = [self.dataSource numberOfTabs:self];
    if ( count == 0 ) {
        return;
    }
    
    for (UIView* view in self.subviews) {
        if ( self.tabsContainer != view ) {
            [view removeFromSuperview];
        }
    }
    
    [self updateContents];
    
    self.selectedIndex = 0;
}

- (UIView *)dequeueReusableViewForIndex:(NSInteger)index
{
    return (UIView *)[self.reusableViews objectForKey:[@(index) description]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateContents];
}

- (void)updateContents
{
    CGFloat titlePadding = 8;
    
    CGRect frame = self.bounds;
    frame.size.height = 44;
    
    self.tabsContainer.frame = frame;
    
    NSUInteger count = [self.dataSource numberOfTabs:self];
    CGSize contentSize = CGSizeMake(0, CGRectGetHeight(self.tabsContainer.frame));
    CGFloat dtx = 0;
    for (int i=0; i<count; i++) {
        UILabel* label = (UILabel *)[self.tabsContainer viewWithTag:10 + i];
        if ( !label ) {
            label = [[UILabel alloc] init];
            [self.tabsContainer addSubview:label];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = 10 + i;
        }
        
        if ( [self.delegate respondsToSelector:@selector(tabs:colorForItemTitleAtIndex:)] ) {
            label.textColor = [self.delegate tabs:self colorForItemTitleAtIndex:i];
        }
        
        NSString* title = [self.dataSource tabs:self titleForItemAtIndex:i];
        CGSize size = [title sizeWithAttributes:@{ NSFontAttributeName:label.font }];
        CGFloat width = size.width + titlePadding * 2;
        label.frame = CGRectMake(dtx, 0, width, CGRectGetHeight(self.tabsContainer.frame));
        label.text = title;
        
        dtx = CGRectGetMaxX(label.frame);
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = label.frame;
        //        [btn setTitle:[@(i) description] forState:UIControlStateNormal];
        btn.tag = 1000 + i;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabsContainer addSubview:btn];
        contentSize.width = CGRectGetMaxX(label.frame);
    }
    
    self.tabsContainer.contentSize = contentSize;
}

- (void)btnClicked:(UIButton *)sender
{
    if ( sender.tag - 1000 == self.selectedIndex ) {
        return;
    }
    
    self.selectedIndex = sender.tag - 1000;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    // 取消选中之前的item
    UILabel* lastLabel = (UILabel *)[self.tabsContainer viewWithTag:10 + _selectedIndex];
    if ( [self.delegate respondsToSelector:@selector(tabs:colorForItemTitleAtIndex:)] ) {
        lastLabel.textColor = [self.delegate tabs:self colorForItemTitleAtIndex:_selectedIndex] ?: [UIColor blackColor];
    } else {
        lastLabel.textColor = [UIColor blackColor];
    }
    
    _selectedIndex = selectedIndex;
    
    UILabel* titleLabel = (UILabel *)[self.tabsContainer viewWithTag:10 + selectedIndex];
    titleLabel.textColor = [UIColor redColor];
    if ( [self.delegate respondsToSelector:@selector(tabs:selectedColorForItemTitleAtIndex:)] ) {
        titleLabel.textColor = [self.delegate tabs:self selectedColorForItemTitleAtIndex:selectedIndex] ?: titleLabel.textColor;
    }
    
    UIView* view = [self.dataSource tabs:self viewForItemAtIndex:selectedIndex];
    //[self viewWithTag:10000 + selectedIndex];
    NSParameterAssert(!!view);
    if ( !view.superview ) {
        CGFloat dty = CGRectGetMaxY(self.tabsContainer.frame);
        view.frame = CGRectMake(0, dty,
                                CGRectGetWidth(self.bounds),
                                CGRectGetHeight(self.bounds) - dty);
        [self addSubview:view];
        
        [self.reusableViews setObject:view forKey:[@(selectedIndex) description]];
    } else {
        [self bringSubviewToFront:view];
    }
    
    if ( [self.delegate respondsToSelector:@selector(tabs:didSelectItemAtIndex:)] ) {
        [self.delegate tabs:self didSelectItemAtIndex:selectedIndex];
    }
}

- (void)dealloc
{
    self.tabsContainer = nil;
}

@end
