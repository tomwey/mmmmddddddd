//
//  PayoutViewController.m
//  zgnx
//
//  Created by tomwey on 6/26/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "PayoutViewController.h"
#import "Defines.h"
#import "LoadDataService.h"

@interface PayoutViewController ()

@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *cardField;
@property (nonatomic, strong) UITextField *moneyField;

@property (nonatomic, strong) LoadDataService *dataService;

@end

@implementation PayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navBar.title = @"提现";
    self.navBar.rightItem = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
                                               @"提交",
                                               [UIColor whiteColor],
                                               self,
                                               @selector(commit));
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.balanceLabel = AWCreateLabel(CGRectMake(0,
                                                 10,
                                                 self.contentView.width,
                                                 34),
                                      [NSString stringWithFormat:@"当前余额%.2f元",
                                       [[[UserService sharedInstance] currentUser].balance floatValue]],
                                      NSTextAlignmentCenter,
                                      nil,
                                      nil);
    [self.contentView addSubview:self.balanceLabel];
    
    // 账号姓名
    self.nameField = [[CustomTextField alloc] initWithFrame:CGRectMake(20,
                                                                   self.balanceLabel.bottom + 10,
                                                                   self.contentView.width - 40,
                                                                   34)];
    [self.contentView addSubview:self.nameField];
    
    self.nameField.placeholder = @"输入账号姓名";
    
    // 提现账号
    self.cardField = [[CustomTextField alloc] initWithFrame:self.nameField.frame];
    [self.contentView addSubview:self.cardField];
    self.cardField.top = self.nameField.bottom + 10;
    self.cardField.placeholder = @"输入支付宝账号或者银行卡号";
    
    // 提现金额
    self.moneyField = [[CustomTextField alloc] initWithFrame:self.nameField.frame];
    [self.contentView addSubview:self.moneyField];
    self.moneyField.top = self.cardField.bottom + 10;
    self.moneyField.placeholder = @"输入提现金额，单位为元";
    
    self.moneyField.keyboardType = UIKeyboardTypeNumberPad;
}

- (void)commit
{
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    __weak typeof(self) me = self;
    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
    [self.dataService POST:@"/payouts" params:@{
                                                @"token": token,
                                                @"card_name": self.nameField.text ?: @"",
                                                @"card_no": self.cardField.text ?: @"",
                                                @"money": self.moneyField.text ? @([self.moneyField.text floatValue]) : @(1),
                                                } completion:^(id result, NSError *error) {
                                                    [MBProgressHUD hideHUDForView:me.contentView animated:YES];
                                                    
                                                    if ( error ) {
                                                        [[Toast showText:error.domain] setBackgroundColor:NAV_BAR_BG_COLOR];
                                                    } else {
                                                        [SimpleToast showText:@"提现申请成功！"];
                                                        [me.navigationController popToRootViewControllerAnimated:YES];
                                                    }
                                                }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.nameField resignFirstResponder];
    [self.cardField resignFirstResponder];
    [self.moneyField resignFirstResponder];
}

- (LoadDataService *)dataService
{
    if ( !_dataService ) {
        _dataService = [[LoadDataService alloc] init];
    }
    return _dataService;
}

@end
