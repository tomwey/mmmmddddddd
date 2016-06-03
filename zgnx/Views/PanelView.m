//
//  PanelView.m
//  zgnx
//
//  Created by tomwey on 6/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "PanelView.h"

@interface PanelView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView* viewsContainer;

@property (nonatomic, strong) NSMutableSet* visiblePages;
@property (nonatomic, strong) NSMutableSet* reusablePages;

@end
@implementation PanelView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.viewsContainer = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:self.viewsContainer];
        self.viewsContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        
        self.viewsContainer.showsHorizontalScrollIndicator = NO;
//        self.viewsContainer.pagingEnabled = YES;
        self.viewsContainer.scrollEnabled = NO;
        
        self.viewsContainer.delegate = self;
        
        self.visiblePages = [NSMutableSet set];
        self.reusablePages = [NSMutableSet set];
        
        _selectedIndex = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.viewsContainer.frame = self.bounds;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self displayContents:_selectedIndex];
    });
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    _selectedIndex = selectedIndex;
    
    [self displayContents:selectedIndex];
    
    UIView* currentView = [self.viewsContainer viewWithTag:100 + selectedIndex];
    [self.viewsContainer scrollRectToVisible:currentView.frame animated:animated
     ];
}

- (void)reloadData
{
    [self.visiblePages enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        UIView* view = (UIView *)obj;
        [view removeFromSuperview];
    }];
    [self.visiblePages removeAllObjects];
    [self.reusablePages removeAllObjects];
    
    _selectedIndex = 0;
    [self displayContents:_selectedIndex];
}

- (void)displayContents:(NSInteger)index
{
    NSInteger count = [self.dataSource numberOfPages:self];
    self.viewsContainer.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * count,
                                                 CGRectGetHeight(self.viewsContainer.frame));
    UIView* view = [self.dataSource panelView:self viewAtIndex:index];
    if ( ![self.visiblePages containsObject:view] ) {
        [self.viewsContainer addSubview:view];
        view.tag = 100 + self.selectedIndex;
        [self.visiblePages addObject:view];
        
        CGRect frame = self.viewsContainer.frame;
        frame.origin.x = index * CGRectGetWidth(frame);
        view.frame = frame;
    }
}

@end
