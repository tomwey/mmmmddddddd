//
//  SearchResultsViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/6/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "Defines.h"
#import "LoadDataService.h"

@interface SearchResultsViewController ()

@property (nonatomic, copy) NSString* keyword;
@property (nonatomic, strong) LoadDataService* dataService;

@end

@implementation SearchResultsViewController

- (instancetype)initWithKeyword:(NSString *)keyword
{
    if ( self = [super init] ) {
        self.keyword = keyword;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = self.keyword;
}

- (void)loadDataForPage:(NSInteger)page
{
    [super loadDataForPage:page];
    
    if ( !self.dataService ) {
        self.dataService = [[LoadDataService alloc] init];
    }
    
    __weak typeof(self)weakSelf = self;
    [self.dataService GET:API_SEARCH_VIDEOS params:@{ @"q" : self.keyword, @"page": @(page) } completion:^(id result, NSError *error) {
        [weakSelf finishLoading:[result objectForKey:@"data"] error:error];
    }];
}

@end
