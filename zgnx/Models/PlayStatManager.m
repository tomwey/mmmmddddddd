//
//  PlayStatManager.m
//  zgnx
//
//  Created by tangwei1 on 16/6/28.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "PlayStatManager.h"
#import "Stream.h"
#import "LoadDataService.h"
#import "Defines.h"

@interface PlayStatManager ()

@property (nonatomic, strong) NSMutableArray *apiServices;

@end
@implementation PlayStatManager

+ (instancetype)sharedInstance
{
    static PlayStatManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[PlayStatManager alloc] init];
        }
    });
    return instance;
}

- (void)playStat:(Stream *)aStream
{
    NSString *sid = [NSString stringWithString:aStream.stream_id];
    BOOL isVOD = ( [aStream.type integerValue] == 2 || [aStream.video_file length] != 0 );
    
    NSString *uri = nil;
    if ( isVOD ) {
        uri = @"/stat/play";
    } else {
        uri = @"/stat/live";
    }
    
    LoadDataService *playService = [[LoadDataService alloc] init];
    [self.apiServices addObject:playService];
    
    [playService GET:uri params:[self playStatParams:sid] completion:^(id result, NSError *error) {
        NSLog(@"play stat: %@", error);
        [self.apiServices removeObject:playService];
    }];
}

- (void)cancelPlayStat:(Stream *)aStream
{
    BOOL isVOD = ( [aStream.type integerValue] == 2 || [aStream.video_file length] != 0 );
    if ( isVOD ) {
        return;
    }
    
    LoadDataService *playService = [[LoadDataService alloc] init];
    [self.apiServices addObject:playService];
    
    NSString *sid = [NSString stringWithString:aStream.stream_id];
    
    [playService GET:@"/stat/cancel_live" params:[self playStatParams:sid] completion:^(id result, NSError *error) {
        NSLog(@"cancel play stat: %@", error);
        [self.apiServices removeObject:playService];
    }];
}

- (NSDictionary *)playStatParams:(NSString *)sid
{
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSString *languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];
    
    return @{
             @"sid": sid ?: @"",
             @"udid" : udid,
             @"m" : AWDeviceName(),
             @"osv" : AWOSVersionString(),
             @"bv" : AWAppVersion(),
             @"sr" : AWDeviceSizeString(),
             @"lc" : languageCode ?: @"zh",
             @"cc" : countryCode ?: @"CN",
             };
}

- (NSMutableArray *)apiServices
{
    if ( !_apiServices ) {
        _apiServices = [[NSMutableArray alloc] init];
    }
    return _apiServices;
}

@end
