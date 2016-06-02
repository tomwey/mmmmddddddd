//
//  SearchViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "SearchViewController.h"
#import "Defines.h"
#import "BannerView.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) BannerView*  bannerView;

@end
@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"搜索";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    
//    self.tableView.dataSource = self;
//    self.tableView.delegate   = self;
    
    self.bannerView = [[BannerView alloc] init];
    
    self.tableView.tableHeaderView = self.bannerView;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bannerView startLoading:nil];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
