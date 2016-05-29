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
#import <AWTableView/UITableView+RemoveBlankCells.h>
#import <AWTableView/UITableView+LoadEmptyOrErrorHandle.h>
#import "Defines.h"

@interface VODListView () <ReloadDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) AWTableViewDataSource* dataSource;

@property (nonatomic, weak) UIRefreshControl* refreshControl;

@end
@implementation VODListView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.dataSource = [[AWTableViewDataSource alloc] initWithArray:nil
                                                         cellClass:@"VideoCell"
                                                        identifier:@"video.cell.id"];
    
    self.tableView =
    [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    
    self.tableView.dataSource = self.dataSource;
    [self addSubview:self.tableView];
    
    self.tableView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.tableView removeBlankCells];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 30 * 2 + 20 + ( AWFullScreenWidth() - 20 ) * 0.618;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startLoad) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    refreshControl.tintColor = NAV_BAR_BG_COLOR;
    
    self.refreshControl = refreshControl;
}

- (void)startLoad
{
    if ( !self.refreshControl.isRefreshing ) {
        [self.refreshControl beginRefreshing];
    }
    
    [self startLoad:^(BOOL succeed) {
        [self.refreshControl endRefreshing];
    }];
}

- (void)startLoad:(void (^)(BOOL))completion
{
    [self.tableView removeErrorOrEmptyTips];
    
    [[VODService sharedInstance] loadWithCatalogID:_catalogID completion:^(id results, NSError *error) {
        if ( [results[@"data"] count] > 0 ) {
            self.dataSource.dataSource = results[@"data"];
            
            [self.tableView reloadData];
        } else {
            [self.tableView showErrorOrEmptyMessage:@"点击重试" reloadDelegate:self];
        }
        
        if ( completion ) {
            completion(!error);
        }
    }];
}

- (void)reloadDataForErrorOrEmpty
{
    if ( self.reloadBlock ) {
        self.reloadBlock(NO);
    }
    [self startLoad:^(BOOL succeed) {
        if ( self.reloadBlock ) {
            self.reloadBlock(succeed);
        }
    }];
}

@end
