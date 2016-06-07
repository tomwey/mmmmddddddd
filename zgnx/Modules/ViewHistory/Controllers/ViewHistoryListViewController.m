//
//  ViewHistoryListViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "ViewHistoryListViewController.h"
#import "Defines.h"
#import "ViewHistoryService.h"

@interface ViewHistoryListViewController ()

@property (nonatomic, strong) ViewHistoryService *vhService;

@end
@implementation ViewHistoryListViewController

- (instancetype)initWithAuthToken:(NSString *)authToken
{
    if ( self = [super init] ) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"历史记录";
    
}

/**
 * 子类重写，并且需要调用super
 */
- (void)loadDataForPage:(NSInteger)page
{
    [super loadDataForPage:page];
    
    if ( !self.vhService ) {
        self.vhService = [[ViewHistoryService alloc] init];
    }
    
    __weak typeof(self)weakSelf = self;
    [self.vhService loadRecordsForUser:[[UserService sharedInstance] currentUser]
                                  page:page
                            completion:^(id result, NSError *error) {
                                [weakSelf finishLoading:result error:error];
                            }];
}

@end
