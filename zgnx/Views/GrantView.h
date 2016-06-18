//
//  GrantView.h
//  zgnx
//
//  Created by tomwey on 6/17/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrantView : UIView

- (void)showInView:(UIView *)view;
- (void)dismiss;

@property (nonatomic, copy) void (^didPayBlock)(CGFloat money, NSString *password);
@property (nonatomic, copy) void (^didCancelBlock)(void);

@end
