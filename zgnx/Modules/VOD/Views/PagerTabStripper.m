//
//  PagerTabStripper.m
//  zgnx
//
//  Created by tomwey on 5/25/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "PagerTabStripper.h"

@interface PagerTabStripper ()

@property (nonatomic, strong) UIScrollView* containerView;
@property (nonatomic, strong) NSMutableArray* stripperArray;

@property (nonatomic, strong) UIView* tabIndicator;

@property (nonatomic, assign) UIView* lastItem;

@end

@implementation PagerTabStripper

static CGFloat const kItemPadding = 6.0;
static CGFloat const kItemSpacing = 6.0;

- (instancetype)initWithTitles:(NSArray *)titles
{
    return [self initWithFrame:CGRectZero withTitles:titles];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withTitles:nil];
}

- (instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray *)titles
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
        self.titles = titles;
    }
    return self;
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
    self.bounds = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]),
                             40);
    
    self.containerView = [[UIScrollView alloc] init];
    [self addSubview:self.containerView];
    
    self.containerView.frame = self.bounds;
    
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.containerView.showsVerticalScrollIndicator =
    self.containerView.showsHorizontalScrollIndicator = NO;
    
    self.titleAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:16],
                              NSForegroundColorAttributeName : [UIColor blackColor]
                              };
    self.selectedColor = [UIColor redColor];
    
    self.stripperArray = [NSMutableArray array];
}

- (void)dealloc
{
    self.containerView = nil;
    self.stripperArray = nil;
    
    self.tabIndicator = nil;
    
    _titles = nil;
    
    self.didSelectBlock = nil;
    
}

- (void)reloadData
{
    for (UIView* item in self.stripperArray) {
        [item removeFromSuperview];
    }
    
    [self.stripperArray removeAllObjects];
    
    NSUInteger i = 0;
    CGSize contentSize = CGSizeMake(0, CGRectGetHeight(self.containerView.frame));
    CGFloat posX = 0;
    for (NSString* title in self.titles) {
        
        CGSize size = [title sizeWithAttributes:self.titleAttributes];
        
        UIView* view = [[UIView alloc] initWithFrame:
                        CGRectMake(0, 0, size.width + kItemPadding * 2, 40)]; // 内间距是6
        [self.containerView addSubview:view];
        
        UILabel* titleLabel = [[UILabel alloc] init];
        titleLabel.frame = view.bounds;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:titleLabel];
        titleLabel.text = title;
        
        titleLabel.tag = 111;
        
        titleLabel.font = self.titleAttributes[NSFontAttributeName];
        titleLabel.textColor = self.titleAttributes[NSForegroundColorAttributeName];
        
        CGRect frame = view.frame;
        frame.origin = CGPointMake(kItemSpacing + posX, 0);
        view.frame = frame;
        
        posX = CGRectGetMaxX(view.frame);
        
        contentSize.width = CGRectGetMaxX(view.frame) + kItemSpacing;
        
        [self.stripperArray addObject:view];
        
        view.tag = i;
        
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
        
        i++;
    }
    
    if ( !self.tabIndicator ) {
        self.tabIndicator = [[UIView alloc] init];
        [self.containerView addSubview:self.tabIndicator];
    }
    
    self.containerView.contentSize = contentSize;
    
    self.selectedIndex = 0;
}

- (void)setTitles:(NSArray *)titles
{
    if ( _titles == titles ) return;
    
    _titles = [titles copy];
    
    [self reloadData];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    if ( selectedIndex > [self.titles count] ) return;
    
    UIView* view = self.stripperArray[selectedIndex];
    
    CGRect frame = view.frame;
    frame.size.height = 2;
    frame.origin.y = CGRectGetHeight(self.containerView.frame) - frame.size.height;
    
    UILabel* label = (UILabel *)[view viewWithTag:111];
    
    [UIView beginAnimations:@"scroll.animation" context:NULL];

    [UIView setAnimationDuration:.35];
    
    self.tabIndicator.frame = frame;
    self.tabIndicator.backgroundColor = self.selectedColor;
    
    label.textColor = self.selectedColor;
    
    UILabel* label2 = (UILabel *)[self.lastItem viewWithTag:111];
    label2.textColor = self.titleAttributes[NSForegroundColorAttributeName];
    
    frame = view.frame;
//    frame.origin.x += kItemSpacing;
    [self.containerView scrollRectToVisible:frame animated:NO];
    
    if ( animated ) {
        [UIView commitAnimations];
    }
    
    self.lastItem = view;
}

- (void)tap:(UIGestureRecognizer *)gesture
{
    [self setSelectedIndex:gesture.view.tag animated:YES];
    if ( self.didSelectBlock ) {
        self.didSelectBlock(self, gesture.view.tag);
        self.didSelectBlock = nil;
    }
}

@end
