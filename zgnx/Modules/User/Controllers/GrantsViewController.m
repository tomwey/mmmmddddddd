//
//  GrantsViewController.m
//  zgnx
//
//  Created by tomwey on 6/12/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "GrantsViewController.h"
#import "Defines.h"
#import "LoadDataService.h"
#import "GrantTableHeaderView.h"

@interface GrantsViewController () <UITableViewDelegate, ReloadDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;
@property (nonatomic, strong) LoadDataService *dataService;
@property (nonatomic, strong) LoadDataService *loadUserDataService;

@property (nonatomic, strong) User *latestUser;
@property (nonatomic, strong) GrantTableHeaderView *tableHeaderView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, assign) BOOL allowLoading;

@end

@implementation GrantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentPage = 1;
    self.hasNextPage = NO;
    self.allowLoading = YES;
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"我打赏别人",
                                                                        @"被别人打赏"]];
    self.segmentedControl.frame = CGRectMake(0, 0, self.contentView.width * 0.618, 34);
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor whiteColor];
    
    self.navBar.titleView = self.segmentedControl;
    
    [self.segmentedControl addTarget:self
                              action:@selector(valueChanged:)
                    forControlEvents:UIControlEventValueChanged];
    
    //
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    
    self.dataSource = [[AWTableViewDataSource alloc] initWithArray:nil
                                                         cellClass:@"GrantCell"
                                                        identifier:@"grant.cell"];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView removeBlankCells];
    
    self.tableHeaderView = [[GrantTableHeaderView alloc] init];
    self.tableHeaderView.grantType = GrantTypeSent;
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadAllData];
    });
}

- (void)loadAllData
{
    if ( self.loadUserDataService == nil ) {
        self.loadUserDataService = [[LoadDataService alloc] init];
    }
    
    [self.tableView removeErrorOrEmptyTips];
    
    __weak typeof(self) me = self;
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
    [self.loadUserDataService GET:API_USER_LOAD_PROFILE
                           params:@{ @"token": token }
                       completion:^(id result, NSError *error)
     {
         [MBProgressHUD hideHUDForView:me.contentView animated:NO];
         if ( error ) {
             [me.tableView showErrorOrEmptyMessage:@"加载出错，点击重试~" reloadDelegate:self];
         } else {
             me.latestUser = [[User alloc] initWithDictionary:[result objectForKey:@"data"]];
             [me loadData];
         }
     }];
}

- (void)valueChanged:(id)sender
{
    self.currentPage = 1;
    
    self.tableHeaderView.grantType = self.segmentedControl.selectedSegmentIndex;
    
    [self loadData];
}

- (void)reloadDataForErrorOrEmpty;
{
    self.currentPage = 1;
//    [self loadData];
    [self loadAllData];
}

- (void)loadData
{
    [self.tableView removeErrorOrEmptyTips];
    self.tableView.hidden = YES;
    
    if ( !self.dataService ) {
        self.dataService = [[LoadDataService alloc] init];
    }
    
    if ( self.currentPage == 1 ) {
        [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    }
    
    __weak typeof(self) me = self;
    
    NSString *uri = self.segmentedControl.selectedSegmentIndex == 0
    ? API_GRANT_SENT
    : API_GRANT_RECEIPT;
    NSString *token = [[[UserService sharedInstance] currentUser] authToken] ?: @"";
    [self.dataService GET:uri
                   params:@{
                            @"token": token,
                            @"page": @(self.currentPage),
                            @"size": @(kPageSize),
                            }
               completion:
     ^(id result, NSError *error) {
         [MBProgressHUD hideAllHUDsForView:me.contentView animated:YES];
         me.allowLoading = YES;
         if ( error ) {
             if ( me.currentPage == 1 ) {
                 [me.tableView showErrorOrEmptyMessage:@"加载出错，点击重试~" reloadDelegate:me];
             }
             me.hasNextPage = NO;
         } else {
             NSArray *data = [result objectForKey:@"data"];
             if ( [data count] == 0 ) {
                 me.hasNextPage = NO;
                 
                 if ( me.currentPage == 1 ) {
                     [me.tableView showErrorOrEmptyMessage:@"Oops, 没有数据~" reloadDelegate:nil];
                 }
             } else {
                 me.hasNextPage = [data count] == kPageSize;
                 
                 if ( me.currentPage == 1 ) {
                     me.dataSource.dataSource = data;
                 } else {
                     NSMutableArray *temp = [NSMutableArray arrayWithArray:me.dataSource.dataSource];
                     [temp addObjectsFromArray:data];
                     me.dataSource.dataSource = temp;
                 }
                 
                 me.tableView.hidden = NO;
                 
                 [me.tableHeaderView setUser:self.latestUser];
                 
                 [me.tableView reloadData];
             }
         }
     }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.hasNextPage && self.allowLoading && [self.dataSource.dataSource count] - 1 == indexPath.row ) {
        self.allowLoading = NO;
        
        self.currentPage ++;
        
        [self loadData];
    }
}

@end
