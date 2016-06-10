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
@property (nonatomic, assign) BOOL needReloadData;

@end

@implementation LikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fromType = StreamFromTypeLike;
    self.needReloadData = NO;
    
    self.navBar.title = @"我的收藏";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateData)
                                                 name:@"kNeedReloadDataNotification"
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.needReloadData ) {
        [self loadDataForPage:1];
    }
}

- (void)updateData
{
    self.needReloadData = YES;
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
