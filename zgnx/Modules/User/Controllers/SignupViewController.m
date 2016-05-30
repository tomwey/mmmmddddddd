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

@property (nonatomic, strong) UITextField* mobileField;
@property (nonatomic, strong) UITextField* passwordField;

@end

@implementation SignupViewController

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
    [self.contentView addSubview:self.passwordField];
    self.passwordField.placeholder = @"密码";
    //    self.passwordField.keyboardType = UIKeyboardType;
    self.passwordField.secureTextEntry = YES;
    
    // 登陆按钮
    UIButton* signupBtn = AWCreateTextButton(self.mobileField.frame, @"注册",
                                            [UIColor whiteColor],
                                            self,
                                            @selector(signup));
    [scrollView addSubview:signupBtn];
    signupBtn.backgroundColor = NAV_BAR_BG_COLOR;
    signupBtn.frame = inputBg.frame;
    signupBtn.top = inputBg2.bottom + 15;
    signupBtn.layer.cornerRadius = 6;
    signupBtn.clipsToBounds = YES;
}

- (void)signup
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
