//
//  VideoListViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/26.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VideoListViewController.h"
#import "Defines.h"
#import "VODService.h"
#import <AWTableView/AWTableViewDataSource.h>

@interface VideoListViewController ()

@property (nonatomic, assign, readwrite) NSUInteger pageIndex;
@property (nonatomic, copy) NSString* catalogID;

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) AWTableViewDataSource* dataSource;

@end
@implementation VideoListViewController

- (instancetype)initWithPageIndex:(NSUInteger)pageIndex catalogID:(NSString*)catalogID
{
    if ( self = [super init] ) {
        self.pageIndex = pageIndex;
        self.catalogID = catalogID;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc");
    self.catalogID = nil;
}

+ (instancetype)videoListVCForPageIndex:(NSUInteger)index forCatalogID:(NSString*)catalogID
{
//    if ( index > 7 ) {
//        return nil;
//    }
    
//    if ( index < 0 ) {
//        return nil;
//    }
    
    return [[self alloc] initWithPageIndex:index catalogID:catalogID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.bounds;
    frame.size.height = self.view.height - 49;
    self.tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    self.tableView.rowHeight = 260;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
//    NSLog(@"pageIndex: %@ -> %d:%@", self, self.pageIndex, self.catalogID);
//    
//    UILabel* label = AWCreateLabel(CGRectMake(30, 30, 50, 30),
//                                   [@(self.pageIndex) description],
//                                   0,
//                                   nil,
//                                   nil);
//    [self.view addSubview:label];
    
    [[VODService sharedInstance] loadWithCatalogID:self.catalogID completion:^(id results, NSError *error) {
//        NSLog(@"%@, %@", results, error);
//
        if ( [results[@"data"] count] > 0 ) {
            self.dataSource = AWTableViewDataSourceCreate(results[@"data"], @"VideoCell", @"video.cell.id");
            
            self.tableView.dataSource = self.dataSource;
            
            [self.tableView reloadData];
        }
        
    }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

@end
