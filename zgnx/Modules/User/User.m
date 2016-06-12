//
//  User.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)jsonResult
{
    if ( self = [super init] ) {
        self.nickname = jsonResult[@"nickname"];
        self.authToken = jsonResult[@"token"];
        self.avatarUrl = jsonResult[@"avatar"];
        self.mobile = jsonResult[@"mobile"];
        self.sentMoney = jsonResult[@"sent_money"];
        self.receiptMoney = jsonResult[@"receipt_money"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.nickname ?: @"" forKey:@"nickname"];
    [aCoder encodeObject:self.authToken ?: @"" forKey:@"token"];
    [aCoder encodeObject:self.avatarUrl ?: @"" forKey:@"avatar"];
    [aCoder encodeObject:self.sentMoney ?: @"" forKey:@"sent_money"];
    [aCoder encodeObject:self.receiptMoney ?: @"" forKey:@"receipt_money"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    User* user = [[User alloc] init];
    user.nickname = [[aDecoder decodeObjectForKey:@"nickname"] description];
    user.authToken = [[aDecoder decodeObjectForKey:@"token"] description];
    user.avatarUrl = [[aDecoder decodeObjectForKey:@"avatar"] description];
    user.sentMoney = [aDecoder decodeObjectForKey:@"sent_money"];
    user.receiptMoney = [aDecoder decodeObjectForKey:@"receipt_money"];
    return user;
}

- (id)copyWithZone:(nullable NSZone *)zone;
{
    User* user = [[User alloc] init];
    user.mobile = self.mobile;
    user.password = self.password;
    user.nickname = self.nickname;
    user.authToken = self.authToken;
    user.avatarUrl = self.avatarUrl;
    user.code = self.code;
    user.sentMoney = self.sentMoney;
    user.receiptMoney = self.receiptMoney;
    return user;
}

@end

@implementation User (Validation)

- (BOOL)validateMobile
{
    NSString* reg = @"^1[3|4|5|7|8][0-9]\\d{4,8}$";
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    if ( [predicate evaluateWithObject:self.mobile] ) {
        return YES;
    }
    return NO;
}

@end
