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
#import "Defines.h"

@interface UserService () <APIManagerDelegate>

@property (nonatomic, strong) APIManager* loadUserInfoManager;
@property (nonatomic, strong) APIManager* apiManager;
@property (nonatomic, strong) APIManager* noDataManager;

@property (nonatomic, strong) APIManager* userLikedVideosAPIManager;

@property (nonatomic, copy) void (^responseCallback)(id result, NSError* error);
@property (nonatomic, copy) void (^noDataCallback)(id result, NSError* error);

@property (nonatomic, strong, readwrite) User* user;

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
//    if (!aUser) return NO;
    
    return !![self currentUser];
}

- (User *)currentUser
{
    if (self.user)
        return self.user;
    
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth.user"];
    if ( !obj ) {
        return nil;
    }
    
    self.user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:obj];
    
    return self.user;
}

- (void)saveUser:(User *)aUser
{
    self.user = aUser;
    
    if ( aUser == nil ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"auth.user"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:aUser] forKey:@"auth.user"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadUserSettingsForAuthToken:(NSString *)authToken
                          completion:(void (^)(NSArray<NSArray *> *, NSError *))completion
{
    NSArray* data = nil;
    if ( !authToken ) {
        data = @[@[@"上传视频", @"我的收藏", @"播放历史", @"清理缓存", @"意见反馈", @"关于"]];
    } else {
        data = @[@[@"我的钱包", @"我的打赏"],
                 @[@"上传视频", @"我的收藏", @"播放历史", @"清理缓存", @"意见反馈", @"关于"],
                 @[@"退出登录"]];
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
              completion:(void (^)(User* aUser, NSError* error))completion
{
    self.responseCallback = completion;
    
    if ( !self.apiManager ) {
        self.apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.apiManager sendRequest:
     APIRequestCreate(API_USER_SIGNUP,
                      RequestMethodPost,
                      @{@"mobile" : mobile,
                        @"password" : password,
                        @"code" : code})];
}

- (void)loginWithMobile:(NSString *)mobile
               password:(NSString *)password
             completion:(void (^)(User* aUser, NSError* error))completion
{
    self.responseCallback = completion;
    
    if ( !self.apiManager ) {
        self.apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.apiManager sendRequest:
     APIRequestCreate(API_USER_LOGIN,
                      RequestMethodPost,
                      @{@"mobile" : mobile,
                        @"password" : password})];
}

- (void)logoutWithAuthToken:(NSString *)authToken
                 completion:(void (^)(id result, NSError* error))completion
{
    [self saveUser:nil];
    
    if ( completion ) {
        completion(@(YES), nil);
    }
}

- (void)fetchCodeWithMobile:(NSString *)mobile completion:(void (^)(id result, NSError* error))completion
{
    self.noDataCallback = completion;
    
    if ( !self.noDataManager ) {
        self.noDataManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.noDataManager sendRequest:
     APIRequestCreate(API_USER_CODE,
                      RequestMethodPost,
                      @{@"mobile" : mobile})];
}

- (void)updatePassword:(NSString *)newPassword
                mobile:(NSString *)mobile
                  code:(NSString *)code
            completion:(void (^)(id result, NSError* error))completion
{
    self.noDataCallback = completion;
    
    if ( !self.noDataManager ) {
        self.noDataManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.noDataManager sendRequest:
     APIRequestCreate(API_USER_UPDATE_PASSWORD,
                      RequestMethodPost,
                      @{@"code" : code ?: @"",
                        @"password" : newPassword ?: @"",
                        @"mobile" : mobile ?: @""
                        })];
}

- (void)loadUserProfileForAuthToken:(NSString *)authToken
                         completion:(void (^)(User* aUser, NSError* error))completion
{
    if ( !authToken ) {
        if ( completion ) {
            completion(nil, nil);
        }
        return;
    }
    
    self.responseCallback = completion;
    if ( !self.apiManager ) {
        self.apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.apiManager sendRequest:APIRequestCreate(API_USER_LOAD_PROFILE, RequestMethodGet, @{ @"token" : authToken } )];
}

- (void)updateUserProfile:(User *)aUser
            withAuthToken:(NSString *)authToken
               completion:(void (^)(User* aUser, NSError* error))completion
{
    self.responseCallback = completion;
    if ( !self.apiManager ) {
        self.apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.apiManager sendRequest:APIRequestCreate(API_USER_UPDATE_NICKNAME, RequestMethodGet, @{ @"token" : authToken } )];
}

/** 网络请求成功回调 */
- (void)apiManagerDidSuccess:(APIManager *)manager
{
    if ( self.apiManager == manager ) {
        if ( self.responseCallback ) {
            id result = [manager fetchDataWithReformer:nil];
            User* user = [[User alloc] initWithDictionary:result[@"data"]];
            
            [self saveUser:user];
            
            self.responseCallback(user, nil);
//            self.responseCallback = nil;
        }
    } else if ( self.noDataManager == manager ) {
        if ( self.noDataCallback ) {
            self.noDataCallback([manager fetchDataWithReformer:nil], nil);
        }
    } else if ( self.userLikedVideosAPIManager == manager ) {
        if ( self.responseCallback ) {
            self.responseCallback([[manager fetchDataWithReformer:nil] objectForKey:@"data"], nil);
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
    } else if ( self.noDataManager == manager ) {
        if ( self.noDataCallback ) {
            self.noDataCallback(nil, [NSError errorWithDomain:manager.apiError.message
                                                         code:manager.apiError.code userInfo:nil]);
        }
    } else if ( self.userLikedVideosAPIManager == manager ) {
        if ( self.responseCallback ) {
            self.responseCallback(nil, [NSError errorWithDomain:manager.apiError.message
                                                           code:manager.apiError.code
                                                       userInfo:nil]);
        }
    }
}

- (void)loadUserLikedVideosWithPage:(NSInteger)pageNo
                         completion:(void (^)(id result, NSError* error))completion
{
    self.responseCallback = completion;
    
    if ( !self.userLikedVideosAPIManager ) {
        self.userLikedVideosAPIManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.userLikedVideosAPIManager sendRequest:
     APIRequestCreate(API_USER_LIKED_VIDEOS,
                      RequestMethodGet,
                      @{@"token" : [[self currentUser] authToken],
                        @"page" : pageNo < 1 ? @"" : @(pageNo),
                        })];
}

@end
