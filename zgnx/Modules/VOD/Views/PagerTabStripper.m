//
//  PagerTabStripper.m
//  BayLe
//
//  Created by tangwei1 on 15/11/20.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "PagerTabStripper.h"

@implementation PagerTabStripper
{
    UIScrollView* _scrollView;
    UIView*       _indicator;
    
    id  _target;
    SEL _action;
}

#define kTitleLabelTag 100

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder:aDecoder] ) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    _selectedIndex = 0;
    _allowShowIndicator = YES;
    _selectedIndicatorColor = [UIColor blackColor];
    _selectedIndicatorSize = 2;
    
    _titleFont = [UIFont systemFontOfSize:15];
    _titleColor = [UIColor blackColor];
    _selectedTitleColor = [UIColor redColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_scrollView];
    
    _scrollView.showsHorizontalScrollIndicator = _scrollView.showsVerticalScrollIndicator = NO;
}

- (void)dealloc
{
    _selectedTitleColor = nil;
    _selectedIndicatorColor = nil;
    
    _titleFont = nil;
    _titleColor = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
    
    CGFloat cellWidth = 0.0;
    if ( [_titles count] <= 2 ) {
        cellWidth = CGRectGetWidth(self.bounds) / 2;
    } else {
        cellWidth = CGRectGetWidth(self.bounds) * 0.382;
    }
    
    // 设置每个tab的frame
    NSInteger count = [[_scrollView subviews] count];
    CGFloat originX = 0;
    for (int i=0; i<count; i++) {
        UIView* view = [_scrollView viewWithTag:1000 + i];
        
        UILabel* titleLabel = (UILabel *)[view viewWithTag:kTitleLabelTag];
        titleLabel.font = _titleFont;
        
        CGSize size = [titleLabel.text sizeWithFont:titleLabel.font
                                  constrainedToSize:CGSizeMake(5000, 1000)];
        CGFloat width = size.width + 10;
        view.frame = CGRectMake(originX, 0, width,
                                CGRectGetHeight(_scrollView.frame));
        
        [[view viewWithTag:kTitleLabelTag] setFrame:view.bounds];
        originX += width + 8;
        
        if ( i == 0 ) {
            // 默认宽度为容器的宽度，高度为2
            
            _indicator.frame = CGRectMake(0,
                                          CGRectGetHeight(_scrollView.frame) - _selectedIndicatorSize,
                                          width,_selectedIndicatorSize);
        }
    }
    
    _scrollView.contentSize = CGSizeMake(originX - 8, CGRectGetHeight(_scrollView.frame));
}

- (void)scrollTo:(CGFloat)dt
{
//    CGRect frame = _indicator.frame;
//    frame.origin.x = dt * _scrollView.contentSize.width;
//    _indicator.frame = frame;
}

- (void)bindTarget:(id)target forAction:(SEL)action;
{
    _target = target;
    _action = action;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    if ( _titleFont != titleFont ) {
        _titleFont = titleFont;
        
        [self setNeedsLayout];
    }
}

- (void)setTitles:(NSArray *)titles
{
    if ( _titles != titles ) {
        _titles = [titles copy];
        
        [self updateContents];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if ( _selectedIndex == selectedIndex ) {
        return;
    }
    
    [self resetCurrentTab];
    
    _selectedIndex = selectedIndex;
    
    [self updateCurrentTab];
}

- (void)resetCurrentTab
{
    UIView* view = [_scrollView viewWithTag:1000 + _selectedIndex];
    
    UILabel* titleLabel = (UILabel *)[view viewWithTag:kTitleLabelTag];
    titleLabel.font = _titleFont;
    titleLabel.textColor = _titleColor;
}

- (void)updateCurrentTab
{
    UIView* view = [_scrollView viewWithTag:1000 + _selectedIndex];
    
    UILabel* titleLabel = (UILabel *)[view viewWithTag:kTitleLabelTag];
    titleLabel.font = _titleFont;
    titleLabel.textColor = _selectedTitleColor;
    
    _indicator.backgroundColor = _selectedIndicatorColor;
    
    CGRect frame = _indicator.frame;
    frame.origin.x = view.frame.origin.x;
    frame.size.width = view.frame.size.width;
    
    [UIView animateWithDuration:.3 animations:^{
        _indicator.frame = frame;
        [_scrollView scrollRectToVisible:view.frame animated:NO];
    }];
}

- (void)updateContents
{
    for (UIView* view in [_scrollView subviews]) {
        [view removeFromSuperview];
    }
    
    // 添加数据
    for (int i=0; i<[_titles count]; i++) {
        NSString* title = _titles[i];
        
        UIView* container = [[UIView alloc] initWithFrame:CGRectZero];
        [_scrollView addSubview:container];
        
        container.tag = 1000 + i;
        
        // 添加标题
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = _titleFont;
        titleLabel.textColor = _titleColor;
        [container addSubview:titleLabel];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        
        titleLabel.tag = kTitleLabelTag;
        
        titleLabel.text = title;
        
        // 添加点击按钮
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = container.bounds;
        [container addSubview:btn];
        
        btn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        // 默认第一个选中
        if ( _selectedIndex == 0 && _selectedIndex == i ) {
            titleLabel.textColor      = _selectedTitleColor;
        }
    }
    
    _indicator = [[UIView alloc] initWithFrame:CGRectZero];
    [_scrollView addSubview:_indicator];
    _indicator = nil;
    
    _indicator.backgroundColor = _selectedIndicatorColor;
    
    [self setNeedsLayout];
}

- (void)btnClicked:(UIButton *)sender
{
    int index = sender.superview.tag - 1000;
    
    self.selectedIndex = index;
    
    if ( [_target respondsToSelector:_action] ) {
        [_target performSelector:_action withObject:self];
    }
}

@end
