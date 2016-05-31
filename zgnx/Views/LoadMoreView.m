//
//  LoadMoreView.m
//  zgnx
//
//  Created by tangwei1 on 16/5/31.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "LoadMoreView.h"
#import "Defines.h"

@interface LoadMoreView ()

@property (nonatomic, weak) UILabel* loadMoreLabel;

@end
@implementation LoadMoreView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        UILabel* label = AWCreateLabel(CGRectMake(0, 0, 150, 30),
                                       nil,
                                       NSTextAlignmentCenter,
                                       nil,
                                       nil);
        [self addSubview:label];
        self.loadMoreLabel = label;
        
        self.loadMoreLabel.text = @"上拉加载更多";
        
        label.center = CGPointMake(AWFullScreenWidth() / 2, self.height / 2);
    }
    return self;
}

/**
 * 默认状态，该组件被添加到视图中
 */
- (void)originState
{
    self.loadMoreLabel.text = @"上拉加载更多";
}

/** 松开刷新 */
- (void)releaseToRefresh
{
    self.loadMoreLabel.text = @"松开加载";
}

/** 开始刷新 */
- (void)changeToRefresh
{
    self.loadMoreLabel.text = @"加载中...";
}

/** 下拉时调用 */
- (void)updateOffset:(CGFloat)dty
{
    
}

/**
 * 回到正常状态时调用
 *
 * 注意：有2种情况会回调该方法，
 * 1) 拖动组件，没有达到临界刷新点，没有刷新
 * 2) 拖动组件，开始刷新，刷新结束
 */
- (void)backToNormalState
{
    self.loadMoreLabel.text = @"上拉加载更多";
}

/**
 * 子类重写返回正确的刷新模式，比如下拉刷新或者上拉加载更多
 */
- (AWRefreshMode)refreshMode
{
    return AWRefreshModePullUpLoadMore;
}

@end
