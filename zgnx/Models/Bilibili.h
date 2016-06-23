//
//  Bilibili.h
//  zgnx
//
//  Created by tomwey on 6/11/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bilibili : NSObject

@property (nonatomic, copy) NSNumber *bid;
@property (nonatomic, copy) NSString *streamId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *sentAt;

- (instancetype)initWithDictionary:(NSDictionary *)jsonResult;

- (NSString *)jsonMessage;

@end
