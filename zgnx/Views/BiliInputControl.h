//
//  BiliInputControl.h
//  zgnx
//
//  Created by tomwey on 6/25/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BiliInputControl : UIView

- (void)hideKeyboard;

@property (nonatomic, copy) void (^didSendMessageBlock)(NSString *msg);

@end
