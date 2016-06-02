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
#import "HotSearchView.h"
#import "LoadDataService.h"
#import "VideoCell.h"

@interface SearchViewController ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) BannerView*  bannerView;
@property (nonatomic, strong) HotSearchView* searchView;

@property (nonatomic, strong) UIView* tableHeaderView;

@property (nonatomic, strong) AWTableViewDataSource* dataSource;

@property (nonatomic, strong) LoadDataService* dataService;

@property (nonatomic, strong) UILabel* likeTipLabel;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"搜索";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    
    self.tableView.backgroundColor = BG_COLOR_GRAY;
    
    self.bannerView = [[BannerView alloc] init];
    self.searchView = [[HotSearchView alloc] initWithRows:4 columns:2];
    self.searchView.backgroundColor = [UIColor whiteColor];
    
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 0)];
    
    [self.tableHeaderView addSubview:self.bannerView];
    [self.tableHeaderView addSubview:self.searchView];
    
    self.dataSource = AWTableViewDataSourceCreate(nil, @"VideoCell", @"video.cell.id");
    self.tableView.dataSource = self.dataSource;
    self.tableView.rowHeight = [VideoCell cellHeight];
    
    [self.tableView removeBlankCells];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
     __weak typeof(SearchViewController) *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bannerView startLoading:^(id selectItem) {
            // 注意此处不会造成循环引用
            NSLog(@"select item: %@", selectItem);
        }];
        [self.searchView startLoading:^(HotSearchView *view) {
            //
            [weakSelf setupTableHeaderView];
        } selectCallback:^(id selectItem) {
            //
        }];
        
        [self startLoadForPage:1];
    });
}

- (void)startLoadForPage:(NSInteger)page
{
    if ( !self.dataService ) {
        self.dataService = [[LoadDataService alloc] init];
    }
    
    __weak typeof(SearchViewController) *weakSelf = self;
    [self.dataService GET:API_VIDEOS_MORE_LIKED params:@{ @"page": @(page) } completion:^(id result, NSError *error) {
//        NSArray* data = result[@"data"];
        if ( error ) {
            NSLog(@"Error: %@", error);
        } else {
            NSArray* data = result[@"data"];
            weakSelf.dataSource.dataSource = data;
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)setupTableHeaderView
{
    self.searchView.left = 0;
    self.searchView.top = self.bannerView.bottom;
    self.tableHeaderView.height = self.searchView.height + self.bannerView.height + self.likeTipLabel.height + 10;
    
    self.likeTipLabel.position = CGPointMake(10, self.searchView.bottom + 10);
    
    self.tableView.tableHeaderView = self.tableHeaderView;
}

- (UILabel *)likeTipLabel
{
    if ( !_likeTipLabel ) {
        _likeTipLabel = AWCreateLabel(CGRectMake(10, 0, self.contentView.width - 20,
                                                 40),
                                      @"  关注最多",
                                      NSTextAlignmentLeft,
                                      nil,
                                      nil);
        _likeTipLabel.backgroundColor = [UIColor whiteColor];
        [self.tableHeaderView addSubview:_likeTipLabel];
    }
    
    return _likeTipLabel;
}

@end
