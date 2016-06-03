//
//  PanelView.h
//  zgnx
//
//  Created by tomwey on 6/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PanelView;
@protocol PanelViewDataSource <NSObject>

- (NSInteger)numberOfPages:(PanelView *)panelView;

- (UIView *)panelView:(PanelView *)panelView viewAtIndex:(NSUInteger)index;

@end

@interface PanelView : UIView

@property (nonatomic, weak) id <PanelViewDataSource> dataSource;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

- (void)reloadData;

@end
