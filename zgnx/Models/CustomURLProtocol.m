//
//  CustomURLProtocol.m
//  zgnx
//
//  Created by tangwei1 on 16/6/22.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "CustomURLProtocol.h"

@implementation CustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSLog(@"url: %@", [request.URL absoluteString]);
    return YES;
}

@end
