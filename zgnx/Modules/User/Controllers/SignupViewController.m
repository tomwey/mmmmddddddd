//
//  SignupViewController.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "SignupViewController.h"
#import "Defines.h"

@interface SignupViewController ()

@property (nonatomic, strong) CustomTextField* mobileField;
@property (nonatomic, strong) CustomTextField* codeField;
@property (nonatomic, strong) CustomTextField* passwordField;

@property (nonatomic, weak) UIButton* fetchCodeButton;

@property (nonatomic, strong) NSTimer* countDownTimer;

@property (nonatomic, assign) NSUInteger totalSeconds;

@end

@implementation SignupViewController

- (void)dealloc
{
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"免费注册";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:scrollView];
    scrollView.showsVerticalScrollIndicator = NO;
    
    UIImageView* logoView = AWCreateImageView(@"zgly_logo_s.png");
    [scrollView addSubview:logoView];
    logoView.center = CGPointMake(self.contentView.width / 2, 20 + logoView.height / 2);
    
    CGFloat fieldWidth = self.contentView.width * 0.7375;
    self.mobileField = [[CustomTextField alloc] initWithFrame:
                        CGRectMake(self.contentView.width / 2 - fieldWidth / 2,
                                   logoView.bottom + 20,
                                   fieldWidth,
                                   37)];
    [scrollView addSubview:self.mobileField];
    self.mobileField.placeholder = @"手机号";
    self.mobileField.keyboardType = UIKeyboardTypeNumberPad;
    
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
    self.passwordField.placeholder = @"密码";
    //    self.passwordField.keyboardType = UIKeyboardType;
    self.passwordField.secureTextEntry = YES;
    
    // 登陆按钮
    UIButton* signupBtn = AWCreateTextButton(self.passwordField.frame, @"注册",
                                            [UIColor whiteColor],
                                            self,
                                            @selector(signup));
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
    
    [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)]];
}

- (void)hideKeyboard
{
    [self.mobileField resignFirstResponder];
    [self.codeField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)fetchCode:(UIButton *)sender
{
    if ( ![self checkMobile] ) return;
    
    self.totalSeconds = 59;
    [self.countDownTimer setFireDate:[NSDate date]];
    self.fetchCodeButton.userInteractionEnabled = NO;
    self.fetchCodeButton.backgroundColor = AWColorFromRGBA(40, 182, 238, 0.7);
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    [[UserService sharedInstance] fetchCodeWithMobile:self.mobileField.text completion:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.contentView animated:YES];
        
        if ( !error ) {
            [Toast showText:@"验证码已发送"].backgroundColor = NAV_BAR_BG_COLOR;
        } else {
            [Toast showText:error.domain].backgroundColor = NAV_BAR_BG_COLOR;
        }
    }];
}

- (BOOL)checkMobile
{
    User* user = [User new];
    user.mobile = self.mobileField.text;
    if ( ![user validateMobile] ) {
        [Toast showText:@"不正确的手机号"].backgroundColor = NAV_BAR_BG_COLOR;
        return NO;
    }
    return YES;
}

- (void)signup
{
    if ( ![self checkMobile] ) return;
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    [[UserService sharedInstance] signupWithMobile:self.mobileField.text
                                          password:self.passwordField.text
                                              code:self.codeField.text
                                        completion:
     ^(User *aUser, NSError *error) {
         
        [MBProgressHUD hideHUDForView:self.contentView animated:YES];
        
        if ( !error ) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [Toast showText:error.domain].backgroundColor = NAV_BAR_BG_COLOR;
        }
    }];
}

- (void)countDown
{
//    NSLog(@"countDown");
    if ( self.totalSeconds == 0 ) {
        [self resetState];
        return;
    }
    
    [self.fetchCodeButton setTitle:[@(self.totalSeconds--) description]
                          forState:UIControlStateNormal];
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
