//
//  WalletViewController.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "WalletViewController.h"
#import "Defines.h"

@interface WalletViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation WalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"我的钱包";
    self.navBar.rightItem = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
                                               @"明细",
                                               [UIColor whiteColor],
                                               self,
                                               @selector(gotoPayHistory));
    
    self.dataSource = @[@[@"充值",@"提现"],
                        @[@"设置支付密码"]];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    self.tableView.rowHeight = 50;
    
    [self.tableView removeBlankCells];
    
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 120)];
    tableHeader.backgroundColor = [UIColor whiteColor];
    
    UILabel *balanceLabel = AWCreateLabel(CGRectMake(0, 0, tableHeader.width, 44),
                                     nil,
                                     NSTextAlignmentCenter,
                                     nil,
                                     [UIColor blackColor]);
    [tableHeader addSubview:balanceLabel];
    balanceLabel.center = [tableHeader centerInBounds];
    balanceLabel.numberOfLines = 2;
    
    self.tableView.tableHeaderView = tableHeader;
    
    User *user = [[UserService sharedInstance] currentUser];
    NSMutableAttributedString *balance = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"当前余额%@元", user.balance ?: @"0"]];
    
    balanceLabel.attributedText = balance;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
    }
    
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( indexPath.section == 0 && indexPath.row == 0 ) {
        // 充值
        UIViewController *payIn = [[NSClassFromString(@"ChargeTipViewController") alloc] init];
        [self.navigationController pushViewController:payIn animated:YES];
    } else if ( indexPath.section == 0 && indexPath.row == 1 ) {
        // 提现
        UIViewController *payout = [[NSClassFromString(@"PayoutViewController") alloc] init];
        [self.navigationController pushViewController:payout animated:YES];
    } else if ( indexPath.section == 1 && indexPath.row == 0 ) {
        // 设置支付密码
        UIViewController *payPass = [[CTMediator sharedInstance] CTMediator_openPasswordVCWithType:3];
        [self.navigationController pushViewController:payPass animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (void)gotoPayHistory
{
    UIViewController *payPass = [[NSClassFromString(@"PayHistoryViewController") alloc] init];
    [self.navigationController pushViewController:payPass animated:YES];
}

@end
