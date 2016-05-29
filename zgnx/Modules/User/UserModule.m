//
//  UserModule.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UserModule.h"
#import "UserViewController.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "UserProfileViewController.h"
#import "FeedbackViewController.h"
#import "AboutViewController.h"
#import "LikesViewController.h"
#import "UploadVideoViewController.h"
#import "WalletViewController.h"

@implementation CTMediator (UserModule)

- (UIViewController *)CTMediator_openUserVCWithAuthToken:(NSString *)authToken
{
    return [[UserViewController alloc] initWithAuthToken:authToken];
}

- (UIViewController *)CTMediator_updateProfile:(User *)user
{
    if (user.authToken) {
        return [[UserProfileViewController alloc] initWithUser:user];
    } else {
        return [[LoginViewController alloc] init];
    }
}

- (UIViewController *)CTMediator_signupWithMobile:(NSString *)mobile
                                             code:(NSString *)code
                                         password:(NSString *)password
{
    return nil;
}

- (UIViewController *)CTMediator_signinWithMobile:(NSString *)mobile
                                         password:(NSString *)password
{
    return nil;
}

- (UIViewController *)CTMediator_updatePasswordWithCode:(NSString *)code
                                            newPassword:(NSString *)password
{
    return nil;
}

- (UIViewController *)CTMediator_openWalletVCForUser:(User *)user
{
    return [[WalletViewController alloc] init];
}

- (UIViewController *)CTMediator_openUploadVCWithAuthToken:(NSString *)token
{
    return [[UploadVideoViewController alloc] init];
}

- (UIViewController *)CTMediator_openLikesVCForUser:(User *)user
{
    return [[LikesViewController alloc] init];
}

- (UIViewController *)CTMediator_openFeedbackVC
{
    return [[FeedbackViewController alloc] init];
}

- (UIViewController *)CTMediator_openAboutVC
{
    return [[AboutViewController alloc] init];
}

@end
