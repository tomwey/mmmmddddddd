//
//  CommonVODListViewController.m
//  zgnx
//
//  Created by tomwey on 5/30/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "CommonVODListViewController.h"
#import "Defines.h"
#import <AWTableView/AWTableViewDataSource.h>
#import "VideoCell.h"

@interface CommonVODListViewController () <UITableViewDelegate, ReloadDelegate>

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong, readwrite) AWTableViewDataSource* dataSource;

@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, assign) BOOL allowLoading;
@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, weak) UIRefreshControl* refreshControl;

@end

@implementation CommonVODListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hasNextPage = NO;
    self.allowLoading = YES;
    
    self.currentPage = 1;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    
    self.dataSource = [[AWTableViewDataSource alloc] initWithArray:nil cellClass:@"VideoCell" identifier:@"video.cell.id"];
    
    self.tableView.dataSource = self.dataSource;
    self.dataSource.tableView = self.tableView;
    self.tableView.delegate   = self;
    
    self.tableView.backgroundColor = BG_COLOR_GRAY;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    
    self.tableView.rowHeight  = [VideoCell cellHeight];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView removeBlankCells];
    
    __weak typeof(self) weakSelf = self;
    self.refreshControl = [self.tableView addRefreshControlWithReloadCallback:^(UIRefreshControl *control) {
        weakSelf.currentPage = 1;
        [weakSelf loadDataForPage:weakSelf.currentPage];
    }];
    self.refreshControl.tintColor = NAV_BAR_BG_COLOR;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidSelect:)
                                                 name:kVideoCellDidSelectNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)videoDidSelect:(NSNotification *)noti
{
    id cellData = [noti.object cellData];
    
    UIViewController* vc =
    [[CTMediator sharedInstance] CTMediator_openVideoStreamVCWithData:cellData fromType:0];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loadDataForPage:(NSInteger)page
{
    if ( page == 1 ) {
        [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    }
    
    NSLog(@"加载：%d", page);
}

- (void)finishLoading:(NSArray *)result error:(NSError *)error
{
    [self.tableView finishLoading];
    
    if ( self.currentPage == 1 ) {
        [MBProgressHUD hideAllHUDsForView:self.contentView animated:YES];
    }
    
    if ( error ) {
        if ( self.currentPage == 1 ) {
            [self.tableView showErrorOrEmptyMessage:@"Oops,失败了,点击重试" reloadDelegate:self];
        } else {
            [Toast showText:@"Oops, 失败了！"];
        }
    } else {
        if ( [result count] == 0 ) {
            self.hasNextPage = NO;
            
            if ( self.currentPage == 1 ) {
                [self.tableView showErrorOrEmptyMessage:@"Oops,没有数据！" reloadDelegate:self];
            } else {
                [Toast showText:@"Oops, 没有更多数据了！"];
            }
        } else {
            self.hasNextPage = [result count] == kPageSize;
            
            if ( self.currentPage == 1 ) {
                self.dataSource.dataSource = result;
            } else {
                NSMutableArray* temp = [NSMutableArray arrayWithArray:self.dataSource.dataSource];
                [temp addObjectsFromArray:result];
                self.dataSource.dataSource = temp;
            }
            
            [self.tableView reloadData];
        }
    }
}

- (void)reloadDataForErrorOrEmpty
{
    self.currentPage = 1;
    [self loadDataForPage:self.currentPage];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.hasNextPage && self.allowLoading && indexPath.row == [self.dataSource.dataSource count] - 1 ) {
        self.allowLoading = NO;
        
        self.currentPage ++;
        
        [self loadDataForPage:self.currentPage];
    }
}

@end
