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

@interface ViewHistoryService ()

@property (nonatomic, strong) ViewHistoryTable* vhTable;

@end

@implementation ViewHistoryService

+ (instancetype)sharedInstance
{
    static ViewHistoryService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[ViewHistoryService alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    if ( self = [super init] ) {
        self.vhTable = [[ViewHistoryTable alloc] init];
    }
    return self;
}

- (void)saveRecord:(ViewHistory *)vh
{
    NSError* error = nil;
    [self.vhTable insertRecord:vh error:&error];
    if ( error ) {
        NSLog(@"error: %@", error);
    }
}

- (void)deleteRecord:(ViewHistory *)vh
{
    NSError* error = nil;
    [self.vhTable deleteRecord:vh error:&error];
    if ( error ) {
        NSLog(@"error: %@", error);
    }
}

- (void)loadRecordsForUser:(User *)user page:(NSInteger)page completion:(void (^)(id result, NSError* error))completion
{
    if ( !user ) {
        
    }
}

- (void)syncRecordsToServer:(void (^)(id result, NSError* error))completion
{
    
}

@end
