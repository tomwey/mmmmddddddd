//
//  UserProfileViewController.h
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "BaseNavBarViewController.h"

@class User;
@interface UserProfileViewController : BaseNavBarViewController

- (instancetype)initWithUser:(User *)user;

@end
