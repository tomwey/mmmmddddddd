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
#import "SearchBar.h"
#import "SearchResultView.h"

@interface SearchViewController () <SearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) BannerView*  bannerView;
@property (nonatomic, strong) HotSearchView* searchView;

@property (nonatomic, strong) UIView* tableHeaderView;

@property (nonatomic, strong) AWTableViewDataSource* dataSource;

@property (nonatomic, strong) LoadDataService* dataService;
@property (nonatomic, strong) LoadDataService* kwDataService;

@property (nonatomic, strong) UILabel* likeTipLabel;

@property (nonatomic, strong) UIButton* rightButton;

@property (nonatomic, strong) SearchResultView* searchResultView;
@property (nonatomic, weak) SearchBar* searchBar;

@property (nonatomic, strong) NSArray* keywordsList;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = self.videoType == 1 ? @"直播搜索" : @"推荐搜索";
    
    SearchBar* searchBar = [[SearchBar alloc] init];
    [self.contentView addSubview:searchBar];
    searchBar.delegate = self;
    self.searchBar = searchBar;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    self.tableView.top = searchBar.bottom;
    self.tableView.height -= searchBar.height;
    
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
    
     __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bannerView startLoading:^(id selectItem) {
            // 注意此处不会造成循环引用
            NSLog(@"select item: %@", selectItem);
            [weakSelf openBanner:selectItem];
        }];
        
        self.searchView.videoType = self.videoType;
        [self.searchView startLoading:^(HotSearchView *view) {
            //
            [weakSelf setupTableHeaderView];
        } selectCallback:^(id selectItem) {
            [weakSelf doSearch:selectItem[@"keyword"]];
        }];
        
        [self startLoadForPage:1];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openStreamDetail:)
                                                 name:kVideoCellDidSelectNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVideoCellDidSelectNotification
                                                  object:nil];
}

- (void)openStreamDetail:(NSNotification *)noti
{
    UIViewController *vc = [[CTMediator sharedInstance] CTMediator_openVideoStreamVCWithStream:[noti.object stream]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.keywordsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
    }
    
    cell.textLabel.text = [[self.keywordsList objectAtIndex:indexPath.row] objectForKey:@"keyword"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( indexPath.row < [self.keywordsList count] ) {
        [self doSearch:[[self.keywordsList objectAtIndex:indexPath.row] objectForKey:@"keyword"]];
    }
}

- (void)searchBar:(SearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ( searchText.length == 0 ) {
        [self.searchResultView prepareForSearching];
    } else {
        if ( !self.kwDataService ) {
            self.kwDataService = [[LoadDataService alloc] init];
        }
        
        [self.searchResultView completeSearching];
        
        __weak typeof(self) weakSelf = self;
        [self.kwDataService GET:API_KEYWORDS_LIST params:@{ @"q" : searchText } completion:^(id result, NSError *error) {
            weakSelf.keywordsList = result[@"data"];
            [weakSelf.searchResultView.searchResultsTableView reloadData];
        }];
    }
}

- (BOOL)searchBarShouldBeginEditing:(SearchBar *)searchBar
{
    self.searchResultView.hidden = NO;
    [self.searchResultView prepareForSearching];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(SearchBar *)searchBar
{
    self.searchResultView.hidden = YES;
    return YES;
}

- (BOOL)searchBarShouldReturn:(SearchBar *)searchBar
{
    self.searchResultView.hidden = YES;
    if ( searchBar.text.length > 0 ) {
        [self doSearch:searchBar.text];
    }
    return YES;
}

- (void)doSearch:(NSString *)keyword
{
    UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openSearchResultsVCWithParams:@{ @"keyword":keyword, @"type": @(self.videoType) }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openBanner:(id)bannerInfo
{
    
}

- (void)startLoadForPage:(NSInteger)page
{
    if ( !self.dataService ) {
        self.dataService = [[LoadDataService alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.dataService GET:API_HOT_SEARCHES params:@{ @"page": @(page),
                                                     @"token": [[UserService sharedInstance] currentUser].authToken ?: @"",
                                                     @"size": @(kPageSize),
                                                     @"type": @(self.videoType)
                                                     } completion:^(id result, NSError *error) {
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
                                      @"  猜你喜欢",
                                      NSTextAlignmentLeft,
                                      nil,
                                      nil);
        _likeTipLabel.backgroundColor = [UIColor whiteColor];
        [self.tableHeaderView addSubview:_likeTipLabel];
    }
    
    return _likeTipLabel;
}

- (SearchResultView *)searchResultView
{
    if ( !_searchResultView ) {
        _searchResultView = [[SearchResultView alloc] init];
        [self.contentView addSubview:_searchResultView];
        _searchResultView.frame = CGRectMake(0,
                                             self.searchBar.bottom,
                                             self.contentView.width,
                                             self.contentView.height - self.searchBar.bottom);
        _searchResultView.searchBar = self.searchBar;
        
        _searchResultView.searchResultsDataSource = self;
        _searchResultView.searchResultsDelegate   = self;
        
        _searchResultView.hidden = YES;
    }
    
    [self.contentView bringSubviewToFront:_searchResultView];
    
    return _searchResultView;
}

@end
