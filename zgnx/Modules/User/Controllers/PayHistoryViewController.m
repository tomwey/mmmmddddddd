//
//  PayHistoryViewController.m
//  zgnx
//
//  Created by tomwey on 6/26/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "PayHistoryViewController.h"
#import "Defines.h"
#import "LoadDataService.h"

@interface PayHistoryViewController () <UITableViewDataSource, ReloadDelegate, UITableViewDelegate>

@property (nonatomic, strong) LoadDataService *dataService;
@property (nonatomic, strong) UITableView     *tableView;

@property (nonatomic, strong) NSMutableArray  *dataSource;

@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, assign) BOOL allowLoading;

@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation PayHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"交易明细";
    
    self.currentPage = 1;
    self.hasNextPage = NO;
    self.allowLoading = YES;
    
    self.dataSource = [NSMutableArray arrayWithCapacity:3];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    self.tableView.rowHeight  = 50;
    
    [self.tableView removeBlankCells];
    
    [self loadData];
}

- (void)loadData
{
    if ( self.currentPage == 1 ) {
        [self.dataSource removeAllObjects];
        
        [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    }
    
    self.tableView.hidden = YES;
    
    [self.tableView removeErrorOrEmptyTips];
    
    __weak typeof(self) me = self;
    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
    [self.dataService GET:@"/pay_histories"
                   params:@{
                            @"token": token,
                            @"page": @(self.currentPage),
                            @"size": @(kPageSize)
                            }
               completion:^(id result, NSError *error)
    {
        [MBProgressHUD hideHUDForView:me.contentView animated:YES];
        me.allowLoading = YES;
        
        if ( error ) {
            [me.tableView showErrorOrEmptyMessage:@"出错了，点击重试!" reloadDelegate:self];
        } else {
            NSArray *data = [result objectForKey:@"data"];
            self.hasNextPage = [data count] >= kPageSize;
            
            if ( self.currentPage == 1 && [data count] == 0 ) {
                [me.tableView showErrorOrEmptyMessage:@"没有数据！" reloadDelegate:nil];
            } else {
                
                [me.dataSource addObjectsFromArray:data];
                
                me.tableView.hidden = NO;
                [me.tableView reloadData];
            }
        }
    }];
}

- (void)reloadDataForErrorOrEmpty
{
    self.currentPage = 1;
    [self loadData];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *moneyLabel = AWCreateLabel(CGRectMake(0, 0,
                                                       self.contentView.width / 2,
                                                       34),
                                            nil,
                                            NSTextAlignmentRight,
                                            nil,
                                            nil);
        cell.accessoryView = moneyLabel;
    }
    
    UILabel *moneyLabel = (UILabel *)cell.accessoryView;
    
    id item = self.dataSource[indexPath.row];
    cell.textLabel.text = item[@"pay_name"];
    cell.detailTextLabel.text = item[@"created_at"];
    
    moneyLabel.text = item[@"pay_money"];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.hasNextPage && self.allowLoading && indexPath.row == [self.dataSource count] - 1 ) {
        self.allowLoading = NO;
        self.currentPage ++;
        [self loadData];
    }
}

- (LoadDataService *)dataService
{
    if ( !_dataService ) {
        _dataService = [[LoadDataService alloc] init];
    }
    return _dataService;
}


@end
