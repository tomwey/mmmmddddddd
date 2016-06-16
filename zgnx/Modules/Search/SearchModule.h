//
//  VideoStreamModule.h
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTMediator.h"

@interface CTMediator (SearchModule)

- (UIViewController *)CTMediator_openSearchVCWithVideoType:(NSUInteger)vType;

- (UIViewController *)CTMediator_openSearchResultsVCWithParams:(NSDictionary *)params;

@end
