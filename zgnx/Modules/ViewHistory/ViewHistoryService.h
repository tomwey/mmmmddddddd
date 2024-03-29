//
//  ViewHistoryService.h
//  zgnx
//
//  Created by tangwei1 on 16/5/31.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Stream;
@class User;
@interface ViewHistoryService : NSObject

//+ (instancetype)sharedInstance;

- (void)saveRecord:(Stream *)vh needSyncServer:(BOOL)flag;

- (BOOL)deleteRecord:(Stream *)vh needSyncServer:(BOOL)flag;

- (void)deleteAllRecords:(BOOL)needSyncServer;

- (void)loadRecordsForUser:(User *)user page:(NSInteger)page completion:(void (^)(id result, NSError* error))completion;

- (void)syncRecordsToServer:(void (^)(id result, NSError* error))completion;

@end
