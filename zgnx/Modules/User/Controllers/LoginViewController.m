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
#import <AWUITools/AWUITools.h>

@interface LoginViewController ()

@property (nonatomic, strong) UITextField* mobileField;
@property (nonatomic, strong) UITextField* passwordField;

@property (nonatomic, weak) UIButton* loginButton;
@property (nonatomic, weak) UIScrollView* scrollView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"登录";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:scrollView];
    scrollView.showsVerticalScrollIndicator = NO;
    
    self.scrollView = scrollView;
    self.scrollView.contentSize = self.scrollView.frame.size;
//    self.scrollView.backgroundColor = [UIColor redColor];
    
    UIImageView* logoView = AWCreateImageView(@"zgly_logo_s.png");
    [scrollView addSubview:logoView];
    logoView.center = CGPointMake(self.contentView.width / 2, 20 + logoView.height / 2);
    
    UIImageView* inputBg = AWCreateImageView(@"login_input_bg.png");
    [scrollView addSubview:inputBg];
    inputBg.center = CGPointMake(scrollView.width / 2, 15 + logoView.bottom + inputBg.height / 2);
    
    self.mobileField = [[UITextField alloc] initWithFrame:CGRectInset(inputBg.frame, 10, 0)];
    [scrollView addSubview:self.mobileField];
    self.mobileField.placeholder = @"手机号";
    self.mobileField.keyboardType = UIKeyboardTypeNumberPad;
    
    UIImageView* inputBg2 = AWCreateImageView(@"login_input_bg.png");
    [scrollView addSubview:inputBg2];
    inputBg2.center = CGPointMake(scrollView.width / 2, 10 + inputBg.bottom + inputBg2.height / 2);
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectInset(inputBg2.frame, 10, 0)];
    [scrollView addSubview:self.passwordField];
    self.passwordField.placeholder = @"密码";
    self.passwordField.secureTextEntry = YES;
    
    // 登陆按钮
    UIButton* loginBtn = AWCreateTextButton(self.mobileField.frame, @"登录",
                                            [UIColor whiteColor],
                                            self,
                                            @selector(login));
    [scrollView addSubview:loginBtn];
    loginBtn.backgroundColor = NAV_BAR_BG_COLOR;
    loginBtn.frame = inputBg.frame;
    loginBtn.top = inputBg2.bottom + 15;
    loginBtn.layer.cornerRadius = 6;
    loginBtn.clipsToBounds = YES;
    
    self.loginButton = loginBtn;
    
    // 注册按钮
    UIButton* signupBtn = AWCreateImageButton(@"me_login_btn_register.png", self, @selector(signup));
    [scrollView addSubview:signupBtn];
    signupBtn.position = CGPointMake(loginBtn.left, loginBtn.bottom + 10);
    
    // 忘记密码按钮
    UIButton* pwdBtn = AWCreateImageButton(@"me_login_btn_password.png", self, @selector(updatePassword));
    [scrollView addSubview:pwdBtn];
    pwdBtn.position = CGPointMake(loginBtn.right - pwdBtn.width, loginBtn.bottom + 10);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)noti
{
//    UIKeyboardAnimationCurveUserInfoKey = 7;
//    UIKeyboardAnimationDurationUserInfoKey = "0.25";
//    UIKeyboardBoundsUserInfoKey = "NSRect: {{0, 0}, {320, 216}}";
//    UIKeyboardCenterBeginUserInfoKey = "NSPoint: {160, 676}";
//    UIKeyboardCenterEndUserInfoKey = "NSPoint: {160, 460}";
//    UIKeyboardFrameBeginUserInfoKey = "NSRect: {{0, 568}, {320, 216}}";
//    UIKeyboardFrameChangedByUserInteraction = 0;
//    UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 352}, {320, 216}}";
    
    CGRect keyboardEndFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect loginBtnFrame = [self.view convertRect:self.loginButton.frame fromView:self.scrollView];
    
    CGFloat dty = CGRectGetHeight(loginBtnFrame) - CGRectGetHeight(keyboardEndFrame);
    if ( dty < 0 ) {
        [UIView animateWithDuration:[noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]
                         animations:
         ^{
             self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetMinY(loginBtnFrame) - CGRectGetMinY(keyboardEndFrame) + self.loginButton.height + 5, 0);
             self.scrollView.contentOffset = CGPointMake(0, CGRectGetMinY(loginBtnFrame) - CGRectGetMinY(keyboardEndFrame) + self.loginButton.height + 5 );
         }];
    } else {
        self.scrollView.contentInset = UIEdgeInsetsZero;
        self.scrollView.contentOffset = CGPointZero;
    }
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    if ( self.scrollView.contentInset.bottom > 0 ) {
        [UIView animateWithDuration:[noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]
                         animations:
         ^{
             self.scrollView.contentInset = UIEdgeInsetsZero;
             self.scrollView.contentOffset = CGPointZero;
         }];
    }
}

- (void)login
{
    User* user = [User new];
    user.mobile = self.mobileField.text;
    if ( ![user validateMobile] ) {
        [Toast showText:@"不正确的手机号"].backgroundColor = NAV_BAR_BG_COLOR;
        return;
    }
    
    [self.mobileField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    [[UserService sharedInstance] loginWithMobile:self.mobileField.text
                                         password:self.passwordField.text
                                       completion:^(User *aUser, NSError *error) {
                                           
                                           [MBProgressHUD hideHUDForView:self.contentView animated:YES];
                                           
                                           if (!error) {
                                               
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                           } else {
                                               [Toast showText:error.domain].backgroundColor = NAV_BAR_BG_COLOR;
                                           }
                                           
                                       }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.mobileField resignFirstResponder];
    [self.passwordField resignFirstResponder];
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
