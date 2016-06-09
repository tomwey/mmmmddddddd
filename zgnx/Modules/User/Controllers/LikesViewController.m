//
//  LikesViewController.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "LikesViewController.h"
#import "Defines.h"
#import "LoadDataService.h"
#import "User.h"

@interface LikesViewController () <ReloadDelegate>

@property (nonatomic, strong) LoadDataService* dataService;

@end

@implementation LikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fromType = StreamFromTypeLike;
    
    self.navBar.title = @"我的收藏";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needReloadData)
                                                 name:@"kNeedReloadDataNotification"
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)needReloadData
{
    [self loadDataForPage:1];
}

- (void)loadDataForPage:(NSInteger)page
{
    [super loadDataForPage:page];
    
    if ( !self.dataService ) {
        self.dataService = [[LoadDataService alloc] init];
    }
    
    [self.dataService GET:API_USER_LIKED_VIDEOS
                   params:@{ @"token": [[[UserService sharedInstance] currentUser] authToken],
                             @"page" : @(page),
                             @"size" : @(kPageSize)
                             }
               completion:^(id result, NSError *error) {
        [self finishLoading:[result objectForKey:@"data"] error:error];
    }];
}

@end
