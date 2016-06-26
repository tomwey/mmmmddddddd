//
//  UpdatePasswordViewController.h
//  zgnx
//
//  Created by tangwei1 on 16/5/30.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "BaseNavBarViewController.h"

typedef NS_ENUM(NSInteger, PasswordType) {
    PasswordTypeEdit = 1,
    PasswordTypeForget = 2,
    PasswordTypePay = 3,
};

@interface UpdatePasswordViewController : BaseNavBarViewController

@property (nonatomic, assign) PasswordType passwordType;

@end
