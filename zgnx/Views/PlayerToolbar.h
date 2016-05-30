//
//  PlayerToolbar.h
//  zgnx
//
//  Created by tangwei1 on 16/5/30.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerToolbar : UIView

- (instancetype)initWithLeftButtonImage:(NSString *)leftImageName
                       rightButtonImage:(NSString *)rightImageName;


@property (nonatomic, copy) void (^leftButtonClickBlock)(PlayerToolbar* player, UIButton* sender);
@property (nonatomic, copy) void (^rightButtonClickBlock)(PlayerToolbar* player, UIButton* sender);

@end
