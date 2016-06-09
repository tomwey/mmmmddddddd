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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cellDidDelete:)
                                                 name:kVideoCellDidDeleteNotification
                                               object:nil];
}

- (void)cellDidDelete:(NSNotification *)noti
{
    Stream *stream = [noti.object stream];
    
    BOOL flag = [self performSelector:@selector(removeStream:) withObject:stream];
    
    if ( !flag ) {
        [[Toast showText:@"删除失败"] setBackgroundColor: NAV_BAR_BG_COLOR];
        return;
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    [self.dataSource.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [obj isKindOfClass:[Stream class]] ) {
            Stream* inStream = (Stream *)obj;
            if ( ![inStream.stream_id isEqualToString:stream.stream_id] ) {
                [temp addObject:obj];
            }
        }
    }];
    self.dataSource.dataSource = temp;
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)videoDidSelect:(NSNotification *)noti
{
    Stream *stream = [noti.object stream];
    stream.fromType = self.fromType;
    UIViewController* vc =
    [[CTMediator sharedInstance] CTMediator_openVideoStreamVCWithStream:stream];
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
            
            NSMutableArray *temp = [NSMutableArray array];
            [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Stream *stream = nil;
                if ( [obj isKindOfClass:[NSDictionary class]] ) {
                    stream = [[Stream alloc] initWithDictionary:obj];
                } else if ( [obj isKindOfClass:[Stream class]] ) {
                    stream = (Stream *)obj;
                }
                stream.fromType = self.fromType;
                if ( stream ) {
                    [temp addObject:stream];
                }
            }];
            
            self.hasNextPage = [result count] == kPageSize;
            
            if ( self.currentPage == 1 ) {
                
                self.dataSource.dataSource = temp;
            } else {
                NSMutableArray* temp1 = [NSMutableArray arrayWithArray:self.dataSource.dataSource];
                [temp1 addObjectsFromArray:temp];
                self.dataSource.dataSource = temp1;
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
