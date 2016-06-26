//
//  User.h
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSNumber* id_;
@property (nonatomic, copy) NSString* mobile;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* nickname;
@property (nonatomic, copy) NSString* authToken;
@property (nonatomic, copy) NSString* avatarUrl;
@property (nonatomic, copy) NSString* code;
@property (nonatomic, copy) NSNumber* sentMoney;
@property (nonatomic, copy) NSNumber* receiptMoney;
@property (nonatomic, copy) NSNumber* balance;

@property (nonatomic, copy, readonly) NSString *hackMobile;

- (instancetype)initWithDictionary:(NSDictionary *)jsonResult;

@end

@interface User (Validation)

- (BOOL)validateMobile;

@end
