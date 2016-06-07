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

@property (nonatomic, strong) ViewHistoryTable* vhTable;

@property (nonatomic, strong) APIManager* apiManager;

@property (nonatomic, copy) void (^responseCallback)(id result, NSError* error);

@end

@implementation ViewHistoryService

//+ (instancetype)sharedInstance
//{
//    static ViewHistoryService* instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if ( !instance ) {
//            instance = [[ViewHistoryService alloc] init];
//        }
//    });
//    return instance;
//}
//
//- (instancetype)init
//{
//    if ( self = [super init] ) {
//        self.vhTable = [[ViewHistoryTable alloc] init];
//    }
//    return self;
//}

- (void)saveRecord:(ViewHistory *)vh needSyncServer:(BOOL)flag
{
    NSError* error = nil;
    
    NSInteger count = [[self.vhTable countWithWhereCondition:@"stream_id = :sid"
                                            conditionParams:@{ @"sid": vh.stream_id }
                                                      error:nil] integerValue];
    if ( count > 0 ) {
        [self.vhTable updateRecord:vh error:&error];
    } else {
        [self.vhTable insertRecord:vh error:&error];
    }
    
    if ( error ) {
        NSLog(@"error: %@", error);
    }
    
    if ( flag ) {
        [self.apiManager sendRequest:APIRequestCreate(API_VIEW_HISTORY_CREATE,
                                                      RequestMethodPost,
                                                      @{
                                                        @"token": vh.loginedUser ? vh.loginedUser.authToken ?: @"" : @"",
                                                        @"viewable_id": vh.video_id ?: @(-1),
                                                        @"progress": vh.currentPlaybackTime ?: @(0),
                                                        @"type" : vh.type ?: @(2),
                                                        })];
    }
    
}

- (void)deleteRecord:(ViewHistory *)vh needSyncServer:(BOOL)flag
{
    NSError* error = nil;
    [self.vhTable deleteRecord:vh error:&error];
    if ( error ) {
        NSLog(@"error: %@", error);
    }
    
    if ( flag ) {
        [self.apiManager sendRequest:APIRequestCreate(API_VIEW_HISTORY_DELETE,
                                                      RequestMethodPost,
                                                      @{
                                                        @"token": vh.loginedUser ? vh.loginedUser.authToken ?: @"" : @"",
                                                        @"viewable_id": vh.vid ?: @(-1),
                                                        @"type" : vh.type ?: @(2),
                                                        })];
    }
}

- (void)loadRecordsForUser:(User *)user page:(NSInteger)page completion:(void (^)(id result, NSError* error))completion
{
    self.responseCallback = completion;
    
    CTPersistanceCriteria* criteria = [[CTPersistanceCriteria alloc] init];
    criteria.orderBy = @"vid";
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
    page = page >= 1 ?: 1;
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

- (ViewHistoryTable *)vhTable
{
    if ( !_vhTable ) {
        _vhTable = [[ViewHistoryTable alloc] init];
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
