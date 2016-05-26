//
//  CatalogService.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VODService.h"
#import "Defines.h"

@interface VODService () <APIManagerDelegate>

@property (nonatomic, strong) APIManager* apiManager;

@property (nonatomic, copy) void (^callback)(id result, NSError *error);

@end

@implementation VODService

+ (instancetype)sharedInstance
{
    static VODService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[VODService alloc] init];
        }
    });
    return instance;
}

- (void)loadWithCatalogID:(NSString *)catalogID completion:(void (^)(id results, NSError* error))completion
{
    if ( !self.apiManager ) {
        self.apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    self.callback = completion;
    
    [self.apiManager sendRequest:APIRequestCreate(API_VOD_LIST, RequestMethodGet, @{ @"cid": catalogID })];
    
}

- (void)apiManagerDidFailure:(APIManager *)manager
{
    if ( manager == self.apiManager ) {
        if ( self.callback ) {
            self.callback(nil, [NSError errorWithDomain:manager.apiError.message
                                                   code:manager.apiError.code
                                               userInfo:nil]);
            self.callback = nil; // 打破循环引用
        }
    }
}

- (void)apiManagerDidSuccess:(APIManager *)manager
{
    if ( manager == self.apiManager ) {
        if ( self.callback ) {
            self.callback([manager fetchDataWithReformer:nil], nil);
            self.callback = nil;
        }
    }
}

@end
