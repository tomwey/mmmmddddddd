//
//  VODListView.m
//  zgnx
//
//  Created by tangwei1 on 16/5/26.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VODListView.h"
#import <AWTableView/AWTableViewDataSource.h>
#import "VODService.h"

@interface VODListView ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) AWTableViewDataSource* dataSource;

@property (nonatomic, strong) UIRefreshControl* refreshControl;

@end
@implementation VODListView
//{
//    NSString * __strong _catalogID;
//}

//@synthesize catalogID = _catalogID;

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
}

- (void)setCatalogID:(NSString *)catalogID
{
//    if ( _catalogID == catalogID ) {
//        return;
//    }
    
    _catalogID = catalogID;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    [self addSubview:self.tableView];
    self.tableView.rowHeight = 260;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    self.refreshControl = refreshControl;
    
    [self loadData];
}

- (void)loadData
{
    [self.refreshControl beginRefreshing];
    
    [[VODService sharedInstance] loadWithCatalogID:_catalogID completion:^(id results, NSError *error) {
        //        NSLog(@"error: %@", error);
        if ( [results[@"data"] count] > 0 ) {
            self.dataSource = [[AWTableViewDataSource alloc] initWithArray:results[@"data"] cellClass:@"VideoCell" identifier:@"video.cell.id"];
            self.tableView.dataSource = self.dataSource;
            [self.tableView reloadData];
        }
        
        [self.refreshControl endRefreshing];
    }];
}

- (void)startRefresh:(UIRefreshControl *)sender
{
    [[VODService sharedInstance] loadWithCatalogID:_catalogID completion:^(id results, NSError *error) {
        //        NSLog(@"error: %@", error);
        if ( [results[@"data"] count] > 0 ) {
            self.dataSource = [[AWTableViewDataSource alloc] initWithArray:results[@"data"] cellClass:@"VideoCell" identifier:@"video.cell.id"];
            self.tableView.dataSource = self.dataSource;
            [self.tableView reloadData];
        }
        
        [self.refreshControl endRefreshing];
    }];
}

@end
