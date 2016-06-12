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

@interface GrantsViewController () <UITableViewDelegate, ReloadDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;
@property (nonatomic, strong) LoadDataService *dataService;

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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
    });
}

- (void)valueChanged:(id)sender
{
    self.currentPage = 1;
    [self loadData];
}

- (void)reloadDataForErrorOrEmpty;
{
    self.currentPage = 1;
    [self loadData];
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
         [MBProgressHUD hideHUDForView:self.contentView animated:YES];
         self.allowLoading = YES;
         if ( error ) {
             if ( self.currentPage == 1 ) {
                 [self.tableView showErrorOrEmptyMessage:@"加载出错，点击重试~" reloadDelegate:self];
             }
             self.hasNextPage = NO;
         } else {
             NSArray *data = [result objectForKey:@"data"];
             if ( [data count] == 0 ) {
                 self.hasNextPage = NO;
                 
                 if ( self.currentPage == 1 ) {
                     [self.tableView showErrorOrEmptyMessage:@"Oops, 没有数据~" reloadDelegate:nil];
                 }
             } else {
                 self.hasNextPage = [data count] == kPageSize;
                 
                 if ( self.currentPage == 1 ) {
                     self.dataSource.dataSource = data;
                 } else {
                     NSMutableArray *temp = [NSMutableArray arrayWithArray:self.dataSource.dataSource];
                     [temp addObjectsFromArray:data];
                     self.dataSource.dataSource = temp;
                 }
                 
                 self.tableView.hidden = NO;
                 [self.tableView reloadData];
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
