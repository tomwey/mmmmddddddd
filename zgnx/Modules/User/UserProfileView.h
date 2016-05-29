//
//  UserProfileView.h
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@interface UserProfileView : UIView

- (instancetype)initWithUser:(User*)aUser;

@property (nonatomic, strong) User* user;

@end
