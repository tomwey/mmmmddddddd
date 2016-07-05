//
//  BiliView.m
//  zgnx
//
//  Created by tomwey on 6/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "BiliView.h"
#import "CustomTextField.h"
#import "Defines.h"
#import "LoadDataService.h"
#import "Bilibili.h"

@interface BiliView () <UITableViewDelegate, ReloadDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, strong) LoadDataService *loadService;
//@property (nonatomic, strong) LoadDataService *sendService;
@property (nonatomic, strong) NSMutableArray *sendServices; // 发送请求集合

@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, assign) BOOL allowLoading;
@property (nonatomic, assign) NSInteger currentPage;

@end
@implementation BiliView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                      style:UITableViewStylePlain];
        [self addSubview:self.tableView];
        
        self.dataSource = AWTableViewDataSourceCreate(nil,
                                                      @"BiliCell",
                                                      @"bili.cell");
        self.tableView.dataSource = self.dataSource;
        self.tableView.delegate   = self;
        
        self.tableView.rowHeight = 90;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.hasNextPage  = NO;
        self.allowLoading = YES;
        self.currentPage  = 1;
        
        self.tableView.backgroundColor = BG_COLOR_GRAY;
    }
    return self;
}

- (void)dealloc
{
    self.loadService = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.sendServices removeAllObjects];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = CGRectMake(0, 0, self.width,
                                      self.height - 50);
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.hasNextPage && self.allowLoading &&
        [self.dataSource.dataSource count] == indexPath.row + 1) {
        self.allowLoading = NO;
        
        self.currentPage ++;
        [self loadData];
    }
}

- (void)setStreamId:(NSString *)streamId
{
    _streamId = streamId;
    
    if ( [streamId length] > 0 ) {
        [self loadData];
    }
}

- (void)loadData
{
    [self.tableView removeErrorOrEmptyTips];
    
    if ( self.currentPage == 1 ) {
        self.tableView.hidden = YES;
    }
    
    NSLog(@"page: %d", self.currentPage);
    
    if ( self.loadService == nil ) {
        self.loadService = [[LoadDataService alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.loadService GET:API_BILI
                   params:@{ @"sid": _streamId ?: @"",
                             @"page": @(self.currentPage),
                             @"size": @(30),
                             }
               completion:^(id result, NSError *error)
    {
        
        [weakSelf handleResult:result error:error];
    }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    self.allowLoading = YES;
    
    if ( error ) {
        if ( self.currentPage == 1 ) {
            [self.tableView showErrorOrEmptyMessage:@"Oops, 加载出错了！点击刷新"
                                     reloadDelegate:self];
        }
        
    } else {
        NSArray *data = [result objectForKey:@"data"];
        if ( [data count] == 0 ) {
            if ( self.currentPage == 1 ) {
                [self.tableView showErrorOrEmptyMessage:@"没有消息，赶快抢沙发吧！" reloadDelegate:nil];
            }
            
        } else {
            
            self.hasNextPage = [data count] >= 30;
            
            if ( self.currentPage == 1 ) {
                self.dataSource.dataSource = data;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kBiliHistoryDidLoadNotification" object:data];
            } else {
                NSMutableArray *temp = [NSMutableArray arrayWithArray:self.dataSource.dataSource];
                [temp addObjectsFromArray:data];
                self.dataSource.dataSource = temp;
            }
            
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        }
    }
}

- (void)reloadDataForErrorOrEmpty
{
    self.currentPage = 1;
    [self loadData];
}

- (void)addJSONMessage:(NSString *)jsonMsg
{
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonMsg dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:0
                                                               error:nil];
    if ( jsonDict ) {
        Bilibili *bili = [[Bilibili alloc] init];
        bili.content = jsonDict[@"msg"];
        bili.nickname = jsonDict[@"nickname"] ?: @"游客";
        bili.avatarUrl = jsonDict[@"avatar"] ?: @"";
        
        [self.tableView removeErrorOrEmptyTips];
        self.tableView.hidden = NO;
        
        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.dataSource.dataSource];
        [temp insertObject:bili atIndex:0];
        self.dataSource.dataSource = temp;
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (void)sendBiliToServer:(Bilibili *)bili
{
    if ( !self.sendServices ) {
        self.sendServices = [NSMutableArray array];
    }
    
    LoadDataService *service = [[LoadDataService alloc] init];
    [self.sendServices addObject:service];
    
    __weak typeof(self) me = self;
    [service POST:API_SEND_BILI
                    params:@{ @"content": bili.content,
                              @"stream_id": bili.streamId ?: @"",
                              @"token": [[UserService sharedInstance] currentUser].authToken ?: @"",
                              }
                completion:^(id result, NSError *error) {
                    [me.sendServices removeObject:service];
                    }];
}

@end
