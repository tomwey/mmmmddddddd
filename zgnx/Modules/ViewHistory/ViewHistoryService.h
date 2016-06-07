//
//  ViewHistoryService.h
//  zgnx
//
//  Created by tangwei1 on 16/5/31.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewHistory;
@class User;
@interface ViewHistoryService : NSObject

//+ (instancetype)sharedInstance;

- (void)saveRecord:(ViewHistory *)vh needSyncServer:(BOOL)flag;

- (void)deleteRecord:(ViewHistory *)vh needSyncServer:(BOOL)flag;

- (void)loadRecordsForUser:(User *)user page:(NSInteger)page completion:(void (^)(id result, NSError* error))completion;

- (void)syncRecordsToServer:(void (^)(id result, NSError* error))completion;

@end
