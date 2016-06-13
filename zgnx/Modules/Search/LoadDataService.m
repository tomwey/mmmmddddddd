//
//  LoadDataService.m
//  zgnx
//
//  Created by tangwei1 on 16/6/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "LoadDataService.h"
#import "Defines.h"

@interface LoadDataService () <APIManagerDelegate>

@property (nonatomic, strong) APIManager* apiManager;

@property (nonatomic, copy) void (^responseCallback)(id result, NSError* error);

@end
@implementation LoadDataService

- (void)dealloc
{
    self.responseCallback = nil;
    self.apiManager.delegate = nil;
    [self.apiManager cancelRequest];
}

- (void)GET:(NSString *)api
     params:(NSDictionary<NSString*, id> *)params
 completion:(void (^)(id result, NSError* error))completion
{
    self.responseCallback = completion;
    [self.apiManager sendRequest:APIRequestCreate(api, RequestMethodGet, params)];
}

- (void)POST:(NSString *)api
      params:(NSDictionary<NSString*, id> *)params
  completion:(void (^)(id result, NSError* error))completion
{
    self.responseCallback = completion;
    
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc] init];
    NSMutableArray *fileParams = [NSMutableArray array];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [obj isKindOfClass:[NSData class]] ) {
            APIFileParam *param = [[APIFileParam alloc] initWithFileData:obj
                                                                    name:key
                                                                fileName:[NSString stringWithFormat:@"%@.jpg",key]
                                                                mimeType:@"image/jpeg"];
            [fileParams addObject:param];
        } else {
            [newParams setObject:obj forKey:key];
        }
    }];
    
    APIRequest *request = APIRequestCreate(api, RequestMethodPost, nil);
    request.params = newParams;
    if ( [fileParams count] > 0 ) {
        request.fileParams = fileParams;
    }
    [self.apiManager sendRequest:request];
}

/** 网络请求开始 */
- (void)apiManagerDidStart:(APIManager *)manager
{
    
}

/** 网络请求完成 */
- (void)apiManagerDidFinish:(APIManager *)manager
{
    
}

/** 网络请求成功回调 */
- (void)apiManagerDidSuccess:(APIManager *)manager
{
    if ( self.responseCallback ) {
        self.responseCallback([manager fetchDataWithReformer:nil], nil);
    }
}

/** 网络请求失败回调 */
- (void)apiManagerDidFailure:(APIManager *)manager
{
    if ( self.responseCallback ) {
        self.responseCallback(nil, [NSError errorWithDomain:manager.apiError.message
                                                       code:manager.apiError.code
                                                   userInfo:nil]);
    }
}

- (APIManager *)apiManager
{
    if ( !_apiManager ) {
        _apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    return _apiManager;
}

@end
