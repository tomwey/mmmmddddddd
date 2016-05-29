//
//  UserService.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "UserService.h"
#import <AWAPIManager/AWAPIManager.h>
#import "User.h"

@interface UserService () <APIManagerDelegate>

@property (nonatomic, strong) APIManager* loadUserInfoManager;
@property (nonatomic, strong) APIManager* apiManager;

@property (nonatomic, copy) void (^responseCallback)(id result, NSError* error);

@end
@implementation UserService

+ (instancetype)sharedInstance
{
    static UserService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[UserService alloc] init];
        }
    });
    return instance;
}

- (BOOL)isLoginedForUser:(User*)aUser
{
    if (!aUser) return NO;
    
    return !![[NSUserDefaults standardUserDefaults] objectForKey:@"auth.user"];
}

- (void)loadUserSettingsForAuthToken:(NSString *)authToken
                          completion:(void (^)(NSArray<NSArray *> *, NSError *))completion
{
    NSArray* data = nil;
    if ( !authToken ) {
        data = @[@[@"上传视频", @"我的收藏", @"播放历史", @"清理缓存", @"意见反馈", @"关于"]];
    } else {
        data = @[@[@"我的钱包"],
                 @[@"上传视频", @"我的收藏", @"播放历史", @"清理缓存", @"意见反馈", @"关于"]];
    }
    
    if (completion)
    {
        completion(data, nil);
    }
}

- (void)fetchUserAuthToken:(void (^)(NSString* authToken, NSError* error))completion
{
    if ( completion ) {
        NSString* authToken = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user.auth.token"] description];
        completion(authToken, nil);
    }
}

- (void)signupWithMobile:(NSString *)mobile
                password:(NSString *)password
                    code:(NSString *)code
{
    if ( !self.apiManager ) {
        self.apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.apiManager sendRequest:APIRequestCreate(api_user_, @{}];
}

- (void)loginWithMobile:(NSString *)mobile
               password:(NSString *)password
             completion:(void (^)(User* aUser, NSError* error))completion
{
    
}

- (void)logoutWithAuthToken:(NSString *)authToken
                 completion:(void (^)(id result, NSError* error))completion
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"auth.user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ( completion ) {
        completion(@(YES), nil);
    }
}

- (void)loadUserProfileForAuthToken:(NSString *)authToken
                         completion:(void (^)(User* aUser, NSError* error))completion
{
    self.responseCallback = completion;
    if ( !self.apiManager ) {
        self.apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    if ( completion ) {
        completion(nil, nil);
    }
}

- (void)updateUserProfile:(User *)aUser
            withAuthToken:(NSString *)authToken
               completion:(void (^)(User* aUser, NSError* error))completion
{
    
}

/** 网络请求成功回调 */
- (void)apiManagerDidSuccess:(APIManager *)manager
{
    if ( self.apiManager == manager ) {
        if ( self.responseCallback ) {
            id result = [manager fetchDataWithReformer:nil];
            User* user = [[User alloc] initWithDictionary:];
            self.responseCallback(result, nil);
            self.responseCallback = nil;
        }
    }
}

/** 网络请求失败回调 */
- (void)apiManagerDidFailure:(APIManager *)manager
{
    if ( self.apiManager == manager ) {
        if ( self.responseCallback ) {
            self.responseCallback(nil, [NSError errorWithDomain:manager.apiError.message code:manager.apiError.code
                                                       userInfo:nil]);
            self.responseCallback = nil;
        }
    }
}

@end
