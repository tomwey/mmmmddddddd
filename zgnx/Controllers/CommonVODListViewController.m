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

@interface CommonVODListViewController ()

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong, readwrite) AWTableViewDataSource* dataSource;

@end

@implementation CommonVODListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    
    self.dataSource = [[AWTableViewDataSource alloc] initWithArray:nil cellClass:@"VideoCell" identifier:@"video.cell.id"];
    
    self.tableView.dataSource = self.dataSource;
    self.dataSource.tableView = self.tableView;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView removeBlankCells];
    
}

@end
