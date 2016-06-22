//
//  DMSManager.h
//  zgnx
//
//  Created by tangwei1 on 16/6/22.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MQTTMessage;
@interface DMSManager : NSObject

+ (instancetype)sharedInstance;

- (void)connect:(void (^)(BOOL succeed, NSError *error))completion;
- (void)disconnect:(void (^)(BOOL succeed, NSError *error))completion;

- (void)subscribe:(NSString *)topic completion:(void (^)(BOOL succeed, NSError *error))completion;
- (void)unsubscribe:(NSString *)topic completion:(void (^)(BOOL succeed, NSError *error))completion;

- (void)sendMessage:(NSString *)msg
            toTopic:(NSString *)topic
         completion:(void (^)(int msgId, NSError *error))completion;

- (void)addMessageHandler:(void (^)(MQTTMessage *message))messageHandler;

@end
