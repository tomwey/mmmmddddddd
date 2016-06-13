//
//  GrantTableHeaderView.h
//  zgnx
//
//  Created by tangwei1 on 16/6/13.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GrantType) {
    GrantTypeSent = 0,    // 打赏别人
    GrantTypeReceipt = 1, // 被别人打赏
};

@class User;
@interface GrantTableHeaderView : UIView

@property (nonatomic, assign) GrantType grantType;

- (void)setUser:(User *)aUser;

@end
