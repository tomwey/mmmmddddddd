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
#import "LoadDataService.h"
#import "ViewHistoryService.h"

@interface CommonVODListViewController () <UITableViewDelegate, ReloadDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong, readwrite) AWTableViewDataSource* dataSource;

@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, assign) BOOL allowLoading;
@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, weak) UIRefreshControl* refreshControl;

@property (nonatomic, strong) LoadDataService *deleteDataService;

@property (nonatomic, strong) UIButton *editButton;
//
//@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) ViewHistoryService *deleteAllVHService;

@end

@implementation CommonVODListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ( self.fromType == StreamFromTypeHistory ||
        self.fromType == StreamFromTypeUploaded) {
        self.editButton = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
                                             @"删除",
                                             [UIColor whiteColor],
                                             self,
                                             @selector(deleteAll));
        self.navBar.rightItem = self.editButton;
    } else {
        self.navBar.rightItem = nil;
    }
    
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
    
    if ( self.fromType == StreamFromTypeHistory ||
         self.fromType == StreamFromTypeUploaded ) {
        NSString *identifier = self.fromType == StreamFromTypeHistory ? @"history" : @"uploaded";
        CGRect frame = self.contentView.bounds;
        frame.origin = CGPointMake(0, self.navBar.bottom);
        [DeleteTipView showTip:identifier inView:self.view frame:frame];
    }
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVideoCellDidSelectNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVideoCellDidDeleteNotification
                                                  object:nil];
}

- (void)deleteAll
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您确定删除所有数据吗？"
                                                    message:@"删除之后不能恢复"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", @"取消", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 0 ) {
        // 删除所有的数据
        if ( self.fromType == StreamFromTypeHistory ) {
            // 删除观看历史
            [self.deleteAllVHService deleteAllRecords:YES];
            self.dataSource.dataSource = nil;
            [self.tableView reloadData];
        } else {
            // 删除所有已经上传的视频
            [self deleteVideo:nil];
        }
    }
}

- (ViewHistoryService *)deleteAllVHService
{
    if (!_deleteAllVHService) {
        _deleteAllVHService = [[ViewHistoryService alloc] init];
    }
    return _deleteAllVHService;
}

- (void)updateDSState
{
    [self.dataSource.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Stream *sObj = nil;
        if ( [obj isKindOfClass:[Stream class]] ) {
            sObj = (Stream *)obj;
            sObj.isEditing = self.isEditing;
        }
    }];
}

- (void)deleteVideo:(Stream *)aStream
{
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    __weak typeof(self) me = self;
    NSString *token = [[[UserService sharedInstance] currentUser] authToken] ?: @"";
    NSDictionary *params = nil;
    if (!aStream) {
        params = @{ @"token" : token };
    } else {
        params = @{
                   @"token": token,
                   @"vid": aStream.id_ ?: @(0),
                   };
    }
    [self.deleteDataService POST:@"/videos/delete"
                          params: params completion:^(id result, NSError *error) {
                                       [MBProgressHUD hideHUDForView:me.contentView animated:YES];
                                       
                                       if ( error ) {
                                           [SimpleToast showText:@"删除失败"];
                                       } else {
                                           if ( !aStream ) {
                                               me.dataSource.dataSource = nil;
                                               [me.tableView reloadData];
                                           } else {
                                               [me reloadDataAndUpdateTable:aStream];
                                           }
                                       }
                                   }];
}

- (void)cellDidDelete:(NSNotification *)noti
{
    Stream *stream = [noti.object stream];
    
    if ( self.fromType == StreamFromTypeUploaded ) {
        [self deleteVideo:stream];
    } else {
        BOOL flag = [self performSelector:@selector(removeStream:) withObject:stream];
        
        if ( !flag ) {
            [[Toast showText:@"删除失败"] setBackgroundColor: NAV_BAR_BG_COLOR];
            return;
        }
        
        [self reloadDataAndUpdateTable:stream];
    }
}

- (void)reloadDataAndUpdateTable:(Stream *)stream
{
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

- (LoadDataService *)deleteDataService
{
    if ( !_deleteDataService ) {
        _deleteDataService = [[LoadDataService alloc] init];
    }
    return _deleteDataService;
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
        self.tableView.hidden = YES;
        [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    }
    
    self.editButton.userInteractionEnabled = NO;
    
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
                stream.isEditing = self.isEditing;
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
            
            self.tableView.hidden = NO;
            [self.tableView reloadData];
            
            self.editButton.userInteractionEnabled = YES;
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
