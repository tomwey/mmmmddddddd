//
//  ViewHistoryService.m
//  zgnx
//
//  Created by tangwei1 on 16/5/31.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "ViewHistoryService.h"
#import "ViewHistory.h"
#import "ViewHistoryTable.h"
#import "Defines.h"
#import "User.h"

@interface ViewHistoryService () <APIManagerDelegate>

@property (nonatomic, strong) StreamTable* vhTable;

@property (nonatomic, strong) APIManager* apiManager;

@property (nonatomic, copy) void (^responseCallback)(id result, NSError* error);

@end

@implementation ViewHistoryService

- (void)saveRecord:(Stream *)vh needSyncServer:(BOOL)flag
{
    NSError* error = nil;
    
    Stream *stream = (Stream *)[self.vhTable findFirstRowWithWhereCondition: @"stream_id = :sid"
                                                  conditionParams:@{ @"sid": [NSString stringWithFormat:@"'%@'", vh.stream_id] }
                                                       isDistinct:YES
                                                            error:&error];
    if ( stream ) {
        vh.identifier = stream.identifier;
        [self.vhTable updateRecord:vh error:&error];
    } else {
        [self.vhTable insertRecord:vh error:&error];
    }
    
    if ( error ) {
        NSLog(@"error: %@", error);
    }
    
    User *user = [[UserService sharedInstance] currentUser];
    NSString *token = user.authToken ?: @"";
    if ( flag ) {
        [self.apiManager sendRequest:APIRequestCreate(API_VIEW_HISTORY_CREATE,
                                                      RequestMethodPost,
                                                      @{
                                                        @"token": token,
                                                        @"viewable_id": vh.id_,
                                                        @"progress": vh.currentPlaybackTime ?: @(0),
                                                        @"type" : vh.type ?: @(2),
                                                        })];
    }
    
}

- (void)dealloc
{
    self.apiManager.delegate = nil;
    [self.apiManager cancelRequest];
}

- (BOOL)deleteRecord:(Stream *)vh needSyncServer:(BOOL)flag
{
    NSError* error = nil;
    [self.vhTable deleteRecord:vh error:&error];
    if ( error ) {
        NSLog(@"error: %@", error);
        return NO;
    }
    
    User *user = [[UserService sharedInstance] currentUser];
    NSString *token = user.authToken ?: @"";
    
    if ( flag ) {
        [self.apiManager sendRequest:APIRequestCreate(API_VIEW_HISTORY_DELETE,
                                                      RequestMethodPost,
                                                      @{
                                                        @"token": token,
                                                        @"viewable_id": vh.id_,
                                                        @"type" : vh.type ?: @(2),
                                                        })];
    }
    return YES;
}

- (void)loadRecordsForUser:(User *)user page:(NSInteger)page completion:(void (^)(id result, NSError* error))completion
{
    self.responseCallback = completion;
    
    CTPersistanceCriteria* criteria = [[CTPersistanceCriteria alloc] init];
    criteria.orderBy = @"identifier";
    criteria.isDESC = YES;
    criteria.isDistinct = YES;
    
    if ( page > 0 ) {
        criteria.limit   = kPageSize;
        criteria.offset  = ( page - 1 ) * kPageSize;
    }
    
    NSError* error = nil;
    NSArray* results = [self.vhTable findAllWithCriteria:criteria error:&error];
    if ( error ) {
        if ( user == nil ) {
            // 用户没有登陆，直接返回错误
            if ( self.responseCallback ) {
                self.responseCallback(nil, error);
            }
        } else {
            // 否则从网络加载数据
            [self loadServerDataForUser:user page:page subError: error];
        }
    } else {
        if ( [results count] > 0 || user == nil ) {
            // 如果本地加载到数据，直接显示
            if ( self.responseCallback ) {
                self.responseCallback(results, nil);
            }
        } else {
            [self loadServerDataForUser:user page:page subError: error];
        }
    }
}

- (void)loadServerDataForUser:(User *)user page:(NSInteger)page subError:(NSError *)error
{
//    page = page >= 1 ?: 1;
    [self.apiManager sendRequest:APIRequestCreate(API_VIEW_HISTORY_LIST, RequestMethodGet, @{ @"token": user.authToken ?: @"",
                                                                                              @"page": @(page),
                                                                                              @"size": @(kPageSize)
                                                                                              })];
}

- (void)syncRecordsToServer:(void (^)(id result, NSError* error))completion
{
    
}

/** 网络请求成功回调 */
- (void)apiManagerDidSuccess:(APIManager *)manager
{
    if ( [manager.apiRequest.uri  isEqualToString: API_VIEW_HISTORY_LIST] ) {
        if ( self.responseCallback ) {
            self.responseCallback([[manager fetchDataWithReformer:nil] objectForKey:@"data"], nil);
        }
    }
}

/** 网络请求失败回调 */
- (void)apiManagerDidFailure:(APIManager *)manager
{
    if ( [manager.apiRequest.uri  isEqualToString: API_VIEW_HISTORY_LIST] ) {
        if ( self.responseCallback ) {
            self.responseCallback(nil, [NSError errorWithDomain:manager.apiError.message
                                                           code:manager.apiError.code
                                                       userInfo:nil]);
        }
    }
}

- (StreamTable *)vhTable
{
    if ( !_vhTable ) {
        _vhTable = [[StreamTable alloc] init];
    }
    return _vhTable;
}

- (APIManager *)apiManager
{
    if ( !_apiManager ) {
        _apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    return _apiManager;
}

@end
