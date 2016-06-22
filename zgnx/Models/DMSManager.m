//
//  DMSManager.m
//  zgnx
//
//  Created by tangwei1 on 16/6/22.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "DMSManager.h"
#import "DMS.h"
#import "MQTTKit.h"

#define CLIENT_ID @"4E50C97A-E36E-4FAC-9BEA-EA2367152191"
#define MQTT_HOST @"mqtt.dms.aodianyun.com"
#define PUB_KEY   @""
#define SUB_KEY   @""

@interface DMSManager ()

@property (nonatomic, strong) DMS *dmsClient;

@end

@implementation DMSManager

+ (instancetype)sharedInstance
{
    static DMSManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[DMSManager alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    if ( self = [super init] ) {
        self.dmsClient = [DMS dmsWithClientId:CLIENT_ID];
    }
    return self;
}

- (void)connect:(void (^)(BOOL succeed, NSError *error))completion
{
    int result = [self.dmsClient connectToHost:MQTT_HOST
                       withPubKey:PUB_KEY
                           subKey:SUB_KEY
                completionHandler:^(MQTTConnectionReturnCode code) {
//                    NSLog(@"code: %d", code);
                    if ( code == ConnectionAccepted ) {
//                        NSLog(@"连接成功！");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ( completion ) {
                                completion(YES, nil);
                            }
                        });
                        
                    } else {
//                        NSLog(@"连接拒绝！");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ( completion ) {
                                completion(NO, [NSError errorWithDomain:@"拒绝连接！" code:code userInfo:nil]);
                            }
                        });
                    }
    }];
    if ( result != DMS_SUCCESS ) {
//        NSLog(@"连接失败！");
        if ( completion ) {
            completion(NO, [NSError errorWithDomain:@"连接失败！" code:-1 userInfo:nil]);
        }
    } else {
        if ( completion ) {
            completion(YES, nil);
        }
    }
}

- (void)disconnect:(void (^)(BOOL succeed, NSError *error))completion
{
    [self.dmsClient disconnectWithCompletionHandler:^(NSUInteger code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completion ) {
                if ( code == DMS_SUCCESS ) {
                    completion(YES, nil);
                } else {
                    completion(NO, [NSError errorWithDomain:@"关闭连接失败" code:code userInfo:nil]);
                }
            }
        });
    }];
}

- (void)subscribe:(NSString *)topic completion:(void (^)(BOOL succeed, NSError *error))completion
{
    [self.dmsClient subscribe:topic withCompletionHandler:^(NSArray *grantedQos) {
        NSLog(@"grantedQos: %@", grantedQos);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completion ) {
                completion(YES, nil);
            }
        });
    }];
}

- (void)unsubscribe:(NSString *)topic completion:(void (^)(BOOL succeed, NSError *error))completion
{
    [self.dmsClient unsubscribe:topic withCompletionHandler:^{
       dispatch_async(dispatch_get_main_queue(), ^{
           if ( completion ) {
               completion(YES, nil);
           }
       });
    }];
}

- (void)sendMessage:(NSString *)msg
            toTopic:(NSString *)topic
         completion:(void (^)(int msgId, NSError *error))completion
{
    [self.dmsClient publishString:msg toTopic:topic completionHandler:^(int mid) {
        NSLog(@"mid: %d", mid);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completion ) {
                completion(mid, nil);
            }
        });
    }];
}

- (void)addMessageHandler:(void (^)(MQTTMessage *message))messageHandler
{
    [self.dmsClient setMessageHandler:messageHandler];
}

@end
