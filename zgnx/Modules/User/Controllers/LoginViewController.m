//
//  LoginViewController.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomNavBar.h"
#import "Defines.h"

@interface LoginViewController ()

@property (nonatomic, strong) UITextField* mobileField;
@property (nonatomic, strong) UITextField* passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"登录";
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:scrollView];
    scrollView.showsVerticalScrollIndicator = NO;
    
    UIImageView* logoView = AWCreateImageView(@"zgly_logo_s.png");
    [scrollView addSubview:logoView];
    logoView.center = CGPointMake(self.contentView.width / 2, 20 + logoView.height / 2);
    
    UIImageView* inputBg = AWCreateImageView(@"login_input_bg.png");
    [scrollView addSubview:inputBg];
    inputBg.center = CGPointMake(scrollView.width / 2, 15 + logoView.bottom + inputBg.height / 2);
    
    self.mobileField = [[UITextField alloc] initWithFrame:CGRectInset(inputBg.frame, 10, 0)];
    [scrollView addSubview:self.mobileField];
    self.mobileField.placeholder = @"手机号";
    
    UIImageView* inputBg2 = AWCreateImageView(@"login_input_bg.png");
    [scrollView addSubview:inputBg2];
    inputBg2.center = CGPointMake(scrollView.width / 2, 10 + inputBg.bottom + inputBg2.height / 2);
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectInset(inputBg2.frame, 10, 0)];
    [self.contentView addSubview:self.passwordField];
    self.passwordField.placeholder = @"密码";
    
    // 登陆按钮
    UIButton* loginBtn = AWCreateTextButton(self.mobileField.frame, @"登录",
                                            [UIColor whiteColor],
                                            self,
                                            @selector(login));
    [self.contentView addSubview:loginBtn];
    loginBtn.backgroundColor = NAV_BAR_BG_COLOR;
    loginBtn.frame = inputBg.frame;
    loginBtn.top = inputBg2.bottom + 15;
    loginBtn.layer.cornerRadius = 6;
    loginBtn.clipsToBounds = YES;
    
    // 注册按钮
    UIButton* signupBtn = AWCreateImageButton(@"me_login_btn_register.png", self, @selector(signup));
    [scrollView addSubview:signupBtn];
    signupBtn.position = CGPointMake(loginBtn.left, loginBtn.bottom + 10);
    
    // 忘记密码按钮
    UIButton* pwdBtn = AWCreateImageButton(@"me_login_btn_password.png", self, @selector(updatePassword));
    [scrollView addSubview:pwdBtn];
    pwdBtn.position = CGPointMake(loginBtn.right - pwdBtn.width, loginBtn.bottom + 10);
}

- (void)login
{
    
    [[UserService sharedInstance] loginWithMobile:self.mobileField.text
                                         password:self.passwordField.text
                                       completion:^(User *aUser, NSError *error) {
                                           
                                       }];
}

- (void)updatePassword
{
    UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openPasswordVC];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)signup
{
    UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openSignupVC];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
