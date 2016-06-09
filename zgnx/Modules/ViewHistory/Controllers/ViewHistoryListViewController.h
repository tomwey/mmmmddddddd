//
//  ViewHistoryListViewController.h
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "CommonVODListViewController.h"

@class Stream;
@interface ViewHistoryListViewController : CommonVODListViewController

- (instancetype)initWithAuthToken:(NSString *)authToken;

- (BOOL)removeStream:(Stream *)aStream;

@end
