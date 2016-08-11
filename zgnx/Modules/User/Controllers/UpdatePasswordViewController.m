//
//  UpdatePasswordViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/30.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UpdatePasswordViewController.h"
#import "Defines.h"
#import "LoadDataService.h"

@interface UpdatePasswordViewController ()

@property (nonatomic, strong) CustomTextField* mobileField;
@property (nonatomic, strong) CustomTextField* codeField;
@property (nonatomic, strong) CustomTextField* passwordField;

@property (nonatomic, weak) UIButton* fetchCodeButton;

@property (nonatomic, strong) NSTimer* countDownTimer;

@property (nonatomic, assign) NSUInteger totalSeconds;

@property (nonatomic, strong) LoadDataService *dataService;

@end

@implementation UpdatePasswordViewController

- (void)dealloc
{
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ( self.passwordType == PasswordTypePay ) {
        self.navBar.title = @"设置支付密码";
        self.dataService = [[LoadDataService alloc] init];
    } else {
        self.navBar.title = @"修改密码";
    }
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:scrollView];
    scrollView.showsVerticalScrollIndicator = NO;
    
    CGFloat fieldWidth = self.contentView.width * 0.7375;
    self.mobileField = [[CustomTextField alloc] initWithFrame:
                        CGRectMake(self.contentView.width / 2 - fieldWidth / 2,
                                   20,
                                   fieldWidth,
                                   37)];
    [scrollView addSubview:self.mobileField];
    self.mobileField.placeholder = @"注册手机号";
    self.mobileField.keyboardType = UIKeyboardTypeNumberPad;
    
    if ( self.passwordType == PasswordTypeForget ) {
        self.mobileField.userInteractionEnabled = YES;
        self.mobileField.textColor = [UIColor blackColor];
    } else {
        self.mobileField.userInteractionEnabled = NO;
        self.mobileField.textColor = [UIColor lightGrayColor];
        
        User *user = [[UserService sharedInstance] currentUser];
        self.mobileField.text = user.hackMobile;
    }
    
    // 验证码
    UIButton* codeBtn = AWCreateTextButton(CGRectMake(0, 0, 120, 37),
                                           @"获取验证码",
                                           [UIColor whiteColor],
                                           self,
                                           @selector(fetchCode:));
    codeBtn.backgroundColor = NAV_BAR_BG_COLOR;
    codeBtn.layer.cornerRadius = 6;
    codeBtn.clipsToBounds = YES;
    [scrollView addSubview:codeBtn];
    codeBtn.position = CGPointMake(self.mobileField.right - codeBtn.width,
                                   self.mobileField.bottom + 10);
    self.fetchCodeButton = codeBtn;
    
    self.codeField = [[CustomTextField alloc] initWithFrame:
                      CGRectMake(self.mobileField.left,
                                 codeBtn.top,
                                 self.mobileField.width - codeBtn.width - 8,
                                 37)];
    [scrollView addSubview:self.codeField];
    self.codeField.placeholder = @"验证码";
    self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.passwordField = [[CustomTextField alloc] initWithFrame:self.mobileField.frame];
    self.passwordField.top = self.codeField.bottom + 10;
    [scrollView addSubview:self.passwordField];
    self.passwordField.placeholder = @"输入新密码";
    //    self.passwordField.keyboardType = UIKeyboardType;
    self.passwordField.secureTextEntry = YES;
    
    // 登陆按钮
    UIButton* signupBtn = AWCreateTextButton(self.passwordField.frame, @"修改密码",
                                             [UIColor whiteColor],
                                             self,
                                             @selector(updatePassword));
    signupBtn.top = self.passwordField.bottom + 20;
    [scrollView addSubview:signupBtn];
    signupBtn.backgroundColor = NAV_BAR_BG_COLOR;
    signupBtn.layer.cornerRadius = 6;
    signupBtn.clipsToBounds = YES;
    
    self.countDownTimer = [NSTimer timerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(countDown) userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer
                                 forMode:NSRunLoopCommonModes];
    [self.countDownTimer setFireDate:[NSDate distantFuture]];
}

- (void)fetchCode:(UIButton *)sender
{
    if ( ![self checkMobile] ) return;
    
    self.totalSeconds = 59;
    [self.countDownTimer setFireDate:[NSDate date]];
//    self.fetchCodeButton.enabled = NO;
    self.fetchCodeButton.userInteractionEnabled = NO;
    self.fetchCodeButton.backgroundColor = AWColorFromRGBA(40, 182, 238, 0.7);
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    NSString *mobile = [[UserService sharedInstance] currentUser].mobile ?: self.mobileField.text;
    [[UserService sharedInstance] fetchCodeWithMobile:mobile completion:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.contentView animated:YES];
        
        if ( !error ) {
            [Toast showText:@"验证码已发送"].backgroundColor = NAV_BAR_BG_COLOR;
        } else {
            [Toast showText:error.domain].backgroundColor = NAV_BAR_BG_COLOR;
        }
    }];
}

- (void)updatePassword
{
    if ( ![self checkMobile] ) return;
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    if ( self.passwordType == PasswordTypePay ) {
        __weak typeof(self) me = self;
        NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
        [self.dataService POST:@"/user/update_pay_password"
                        params:@{
                                    @"token": token,
                                    @"code": self.codeField.text ?: @"",
                                    @"pay_password": self.passwordField.text ?: @""
                                                                     }
                    completion:^(id result, NSError *error) {
                        [MBProgressHUD hideHUDForView:me.contentView animated:YES];
                        
                        if ( !error ) {
                            [SimpleToast showText:@"设置支付密码成功"];
                            [self.navigationController popViewControllerAnimated:YES];
                        } else {
                            [Toast showText:error.domain].backgroundColor = NAV_BAR_BG_COLOR;
                        }
                    }];
    } else {
        NSString *mobile = [[UserService sharedInstance] currentUser].mobile ?: self.mobileField.text;
        [[UserService sharedInstance] updatePassword:self.passwordField.text
                                              mobile:mobile
                                                code:self.codeField.text
                                          completion:
         ^(id result, NSError *error) {
             
             [MBProgressHUD hideHUDForView:self.contentView animated:YES];
             
             if ( !error ) {
                 [SimpleToast showText:@"修改密码成功"];
                 [self.navigationController popViewControllerAnimated:YES];
             } else {
                 [Toast showText:error.domain].backgroundColor = NAV_BAR_BG_COLOR;
             }
         }];
    }
}

- (BOOL)checkMobile
{
    User* user = [User new];
    
    NSString *mobile = [[UserService sharedInstance] currentUser].mobile ?: self.mobileField.text;
    
    user.mobile = mobile;//self.mobileField.text;
    if ( ![user validateMobile] ) {
        [Toast showText:@"不正确的手机号"].backgroundColor = NAV_BAR_BG_COLOR;
        return NO;
    }
    return YES;
}

- (void)countDown
{
    //    NSLog(@"countDown");
    if ( self.totalSeconds == 0 ) {
        [self resetState];
        return;
    }
    
    NSString *title = [@(self.totalSeconds) description];
    [self.fetchCodeButton setTitle:title
                          forState:UIControlStateNormal];
    
    self.totalSeconds --;
//    NSLog(@"%d", self.totalSeconds);
    //    NSLog(@"%d", self.totalSeconds);
    
}

- (void)resetState
{
    [self.countDownTimer
     setFireDate:[NSDate distantFuture]];
    self.fetchCodeButton.userInteractionEnabled = YES;
    [self.fetchCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    self.fetchCodeButton.backgroundColor = NAV_BAR_BG_COLOR;
}

@end
