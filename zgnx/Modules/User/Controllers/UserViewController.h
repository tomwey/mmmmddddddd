//
//  UserViewController.h
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavBarViewController.h"

@interface UserViewController : BaseNavBarViewController

- (instancetype)initWithAuthToken:(NSString *)authToken;

@end
