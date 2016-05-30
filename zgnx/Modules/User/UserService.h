//
//  UserService.h
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@interface UserService : NSObject

+ (instancetype)sharedInstance;

- (User *)currentUser;

- (BOOL)isLoginedForUser:(User*)aUser;

- (void)loadUserSettingsForAuthToken:(NSString *)authToken
                          completion:(void (^)(NSArray<NSArray *>* result, NSError* error))completion;

- (void)fetchUserAuthToken:(void (^)(NSString* authToken, NSError* error))completion;

- (void)fetchCodeWithMobile:(NSString *)mobile completion:(void (^)(id result, NSError* error))completion;

- (void)signupWithMobile:(NSString *)mobile
                password:(NSString *)password
                    code:(NSString *)code
              completion:(void (^)(User* aUser, NSError* error))completion;

- (void)loadUserProfileForAuthToken:(NSString *)authToken
                         completion:(void (^)(User* aUser, NSError* error))completion;

- (void)loginWithMobile:(NSString *)mobile
               password:(NSString *)password
             completion:(void (^)(User* aUser, NSError* error))completion;
- (void)logoutWithAuthToken:(NSString *)authToken
                 completion:(void (^)(id result, NSError* error))completion;

- (void)updateUserProfile:(User *)aUser
            withAuthToken:(NSString *)authToken
               completion:(void (^)(User* aUser, NSError* error))completion;

@end
