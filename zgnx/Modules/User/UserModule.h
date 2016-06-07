//
//  UserModule.h
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTMediator.h"

#import "User.h"
#import "UserService.h"

@interface CTMediator (UserModule)

- (UIViewController *)CTMediator_openUserVCWithAuthToken:(NSString *)authToken;

- (UIViewController *)CTMediator_openSignupVC;

- (UIViewController *)CTMediator_openLoginVC;

- (UIViewController *)CTMediator_signinWithMobile:(NSString *)mobile
                                         password:(NSString *)password;

- (UIViewController *)CTMediator_updatePasswordWithCode:(NSString *)code
                                            newPassword:(NSString *)password;

- (UIViewController *)CTMediator_updateProfile:(User *)user;

- (UIViewController *)CTMediator_openWalletVCForUser:(User *)user;

- (UIViewController *)CTMediator_openUploadVCWithAuthToken:(NSString *)token;

- (UIViewController *)CTMediator_openLikesVCForUser:(User *)user;

- (UIViewController *)CTMediator_openFeedbackVC;

- (UIViewController *)CTMediator_openAboutVC;

- (UIViewController *)CTMediator_openPasswordVC;

@end
