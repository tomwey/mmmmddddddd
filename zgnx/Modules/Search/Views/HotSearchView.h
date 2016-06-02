//
//  HotSearchView.h
//  zgnx
//
//  Created by tangwei1 on 16/6/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotSearchView : UIView

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns;

- (void)startLoading:(void (^)(HotSearchView *view))completion selectCallback:(void (^)(id selectItem))selectCallback;

@end
