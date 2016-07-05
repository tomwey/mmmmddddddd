//
//  LiveService.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "LiveService.h"
#import "Defines.h"
#import "UserService.h"

@interface LiveService () <APIManagerDelegate>

@property (nonatomic, strong) APIManager* livingVideoAPIManager;
@property (nonatomic, strong) APIManager* hotLivedVideoAPIManager;

@property (nonatomic, copy) void (^livingAPIResponseCallback)(NSArray* results, NSError* error);

@property (nonatomic, copy) void (^hotLivedAPIResponseCallback)(NSArray* results, NSError* error);

@end
@implementation LiveService

+ (instancetype)sharedInstance
{
    static LiveService* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[LiveService alloc] init];
        }
    });
    return instance;
}

- (void)loadLivingVideos:(void (^)(NSArray* result, NSError* error))completion
{
    self.livingAPIResponseCallback = completion;
    if ( !self.livingVideoAPIManager ) {
        self.livingVideoAPIManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
    [self.livingVideoAPIManager sendRequest:APIRequestCreate(API_LIVING_VIDOES, RequestMethodGet, @{ @"token": token, @"pl": @"iOS" } )];
}

- (void)loadHotLivedVideosForPage:(NSInteger)pageNo
                       completion:(void (^)(NSArray* results, NSError* error))completion
{
    self.hotLivedAPIResponseCallback = completion;
    if ( !self.hotLivedVideoAPIManager ) {
        self.hotLivedVideoAPIManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    NSDictionary* params = nil;
    if ( pageNo > 0 ) {
        params = @{ @"page" : @(pageNo), @"size": @(kPageSize) };
    }
    [self.hotLivedVideoAPIManager sendRequest:APIRequestCreate(API_HOT_LIVED_VIDEOS, RequestMethodGet, params )];
}

/** 网络请求成功回调 */
- (void)apiManagerDidSuccess:(APIManager *)manager
{
    NSArray* result = [[manager fetchDataWithReformer:nil] objectForKey:@"data"];
    
    if ( self.livingVideoAPIManager == manager ) {
        if ( self.livingAPIResponseCallback ) {
            self.livingAPIResponseCallback(result, nil);
            self.livingAPIResponseCallback = nil;
        }
    } else if ( self.hotLivedVideoAPIManager == manager ) {
        if ( self.hotLivedAPIResponseCallback ) {
            self.hotLivedAPIResponseCallback(result, nil);
            self.hotLivedAPIResponseCallback = nil;
        }
    }
}

/** 网络请求失败回调 */
- (void)apiManagerDidFailure:(APIManager *)manager
{
    NSError* error = [NSError errorWithDomain:manager.apiError.message
                                         code:manager.apiError.code
                                     userInfo:nil];
    
    if ( self.livingVideoAPIManager == manager ) {
        if ( self.livingAPIResponseCallback ) {
            self.livingAPIResponseCallback(nil, error);
            self.livingAPIResponseCallback = nil;
        }
    } else if ( self.hotLivedVideoAPIManager == manager ) {
        if ( self.hotLivedAPIResponseCallback ) {
            self.hotLivedAPIResponseCallback(nil, error);
            self.hotLivedAPIResponseCallback = nil;
        }
    }
}

@end
