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
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.nickname ?: @"" forKey:@"nickname"];
    [aCoder encodeObject:self.authToken ?: @"" forKey:@"token"];
    [aCoder encodeObject:self.avatarUrl ?: @"" forKey:@"avatar"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    User* user = [[User alloc] init];
    user.nickname = [[aDecoder decodeObjectForKey:@"nickname"] description];
    user.authToken = [[aDecoder decodeObjectForKey:@"token"] description];
    user.avatarUrl = [[aDecoder decodeObjectForKey:@"avatar"] description];
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
