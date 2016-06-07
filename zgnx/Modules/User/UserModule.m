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
#import "UpdatePasswordViewController.h"

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

- (UIViewController *)CTMediator_openSignupVC
{
    return [[SignupViewController alloc] init];
}

- (UIViewController *)CTMediator_openLoginVC
{
    return [[LoginViewController alloc] init];
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
    if ( [[UserService sharedInstance] isLoginedForUser:nil] == NO ) {
        return [[LoginViewController alloc] init];
    }
    
    return [[WalletViewController alloc] init];
}

- (UIViewController *)CTMediator_openUploadVCWithAuthToken:(NSString *)token
{
    if ( [[UserService sharedInstance] isLoginedForUser:nil] == NO ) {
        return [[LoginViewController alloc] init];
    }
    return [[UploadVideoViewController alloc] init];
}

- (UIViewController *)CTMediator_openLikesVCForUser:(User *)user
{
    if ( [[UserService sharedInstance] isLoginedForUser:nil] == NO ) {
        return [[LoginViewController alloc] init];
    }
    
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

- (UIViewController *)CTMediator_openPasswordVC
{
    return [[UpdatePasswordViewController alloc] init];
}

@end
