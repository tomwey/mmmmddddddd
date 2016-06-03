//
//  SmallToolbar.h
//  zgnx
//
//  Created by tangwei1 on 16/6/3.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ToolbarButtonTag) {
    ToolbarButtonTagBili  = 100,
    ToolbarButtonTagShare = 101,
    ToolbarButtonTagLike  = 102,
};

@interface SmallToolbar : UIView

- (instancetype)initWithVideoInfo:(id)videoInfo;

@property (nonatomic, strong) id videoInfo;

@property (nonatomic, copy) void (^toolbarButtonDidTapBlock)(UIButton* sender);

@end
