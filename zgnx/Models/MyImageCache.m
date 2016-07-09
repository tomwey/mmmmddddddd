//
//  MyImageCache.m
//  zgnx
//
//  Created by tomwey on 7/9/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "MyImageCache.h"
#import "Defines.h"

@implementation MyImageCache

static inline NSString * MyImageCacheKeyFromURLRequest(NSURLRequest *request) {
    NSString *url = [[request URL] absoluteString];
    NSString *key = [[[url componentsSeparatedByString:@"?"] firstObject] description];
    NSLog(@"key: %@", key);
    return key;
}

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
    return [self objectForKey:MyImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:MyImageCacheKeyFromURLRequest(request)];
    }
}

@end
