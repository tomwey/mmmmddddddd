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
    
    self.navBar.title = @"我的收藏";
}

- (void)loadDataForPage:(NSInteger)page
{
    [super loadDataForPage:page];
    
    if ( !self.dataService ) {
        self.dataService = [[LoadDataService alloc] init];
    }
    
    [self.dataService GET:API_USER_LIKED_VIDEOS params:@{ @"token": [[[UserService sharedInstance] currentUser] authToken],
                                                          @"page" : @(page)
                                                          } completion:^(id result, NSError *error) {
        [self finishLoading:[result objectForKey:@"data"] error:error];
    }];
}

@end
