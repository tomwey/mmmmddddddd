//
//  UserModule.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UserModule.h"
#import "UserViewController.h"

@implementation CTMediator (UserModule)

- (UIViewController *)CTMediator_openUserVCWithAuthToken:(NSString *)authToken
{
    return [[UserViewController alloc] initWithAuthToken:authToken];
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

@end
