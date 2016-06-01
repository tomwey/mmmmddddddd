//
//  LiveViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "LiveViewController.h"
#import "Defines.h"
#import "LiveThumbView.h"
#import "VideoCell.h"
#import "LiveService.h"
#import <AWTableView/UITableView+LoadEmptyOrErrorHandle.h>

@interface LiveViewController () <UITableViewDataSource, UITableViewDelegate, ReloadDelegate>

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* livingDataSource;
@property (nonatomic, strong) NSMutableArray* hotLivedDataSource;

@end
@implementation LiveViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        
        [self createTabBarItemWithTitle:@"直播"
                                  image:[UIImage imageNamed:@"tab_live_n.png"]
                          selectedImage:[UIImage imageNamed:@"tab_live_s.png"]
           titleTextAttributesForNormal:nil
         titleTextAttributesForSelected:@{ NSForegroundColorAttributeName: TABBAR_TITLE_SELECTED_COLOR }];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.livingDataSource = [NSMutableArray array];
    self.hotLivedDataSource = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    self.tableView.height -= 49;
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    self.tableView.backgroundColor = BG_COLOR_GRAY;//[UIColor whiteColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 简单处理
    self.tableView.rowHeight = [VideoCell cellHeight];
    
    [self.tableView removeBlankCells];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    
//    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor whiteColor]];
    
    // 添加下拉刷新控件
    __weak typeof(self)weakSelf = self;
    [[self.tableView addRefreshControlWithReloadCallback:^(UIRefreshControl* control) {
        if ( !control ) {
            
        }
        [weakSelf startLoad];
    }] setTintColor:NAV_BAR_BG_COLOR];
    
}

- (void)reloadDataForErrorOrEmpty
{
    
    [self startLoad];
}

- (void)startLoad
{
    [self.livingDataSource removeAllObjects];
    [self.hotLivedDataSource removeAllObjects];
    
    self.tableView.hidden = YES;
    
    [self.tableView removeErrorOrEmptyTips];
    
    [[LiveService sharedInstance] loadLivingVideos:^(NSArray *result, NSError *error) {
        if ( result ) {
            [self.livingDataSource addObjectsFromArray:result];
        }
        
        [self startLoadHotVideos:-1];
    }];
}

- (void)startLoadHotVideos:(NSInteger)page
{
    [[LiveService sharedInstance] loadHotLivedVideosForPage:page completion:^(NSArray *results, NSError *error) {
        
        if ( results ) {
            [self.hotLivedDataSource addObjectsFromArray:results];
        }
        
        if ( [self.hotLivedDataSource count] == 0 &&
            [self.livingDataSource count] == 0) {
            [self.tableView showErrorOrEmptyMessage:@"Oops, 没有数据！" reloadDelegate:self];
        } else {
            [self.tableView removeErrorOrEmptyTips];
            self.tableView.hidden = NO;
            
            [self.tableView reloadData];
        }
        
        [self.tableView finishLoading];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count1 = [self.livingDataSource count] > 0 ? 1 : 0;
    NSInteger count2 = [self.hotLivedDataSource count] > 0 ? 1 : 0;
    return count1 + count2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.livingDataSource count];
        case 1:
            return [self.hotLivedDataSource count];
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCell* cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell.id"];
    }
    
    NSArray* array = indexPath.section == 0 ? self.livingDataSource : self.hotLivedDataSource;

    id obj = nil;
    if ( indexPath.row < [array count] ) {
        obj = [array objectAtIndex:indexPath.row];
    }

    [cell configData:obj];
    
    __weak typeof(self) weakSelf = self;
    cell.didSelectItem = ^(VideoCell* cell) {
        UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openVideoStreamVCWithData:obj];
        [weakSelf presentViewController:vc animated:YES completion:nil];
    };
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel* titleLabel = (UILabel *)[view viewWithTag:10011];
    if ( !titleLabel ) {
        titleLabel = AWCreateLabel(CGRectMake(10, 10, self.contentView.width - 20, 30),
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(16, NO),
                                   [UIColor blackColor]);
        
        [view addSubview:titleLabel];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.tag = 10011;
    }
    
    if ( section == 0 ) {
        titleLabel.text = @"  正在直播";
    } else if ( section == 1 ) {
        titleLabel.text = @"  热门直播";
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

@end
