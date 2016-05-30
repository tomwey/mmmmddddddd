//
//  FeedbackViewController.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Defines.h"

@interface FeedbackViewController () <UITextViewDelegate, APIManagerDelegate>

@property (nonatomic, weak) UITextView* bodyView;
@property (nonatomic, weak) UITextField* authorField;

@property (nonatomic, weak) UILabel* textViewPlaceholder;

@property (nonatomic, strong) APIManager* apiManager;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"意见反馈";
    
//    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UITextView* contentArea = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.contentView.width - 20,
                                                                              120)];
    [self.contentView addSubview:contentArea];
//    contentArea.text = @"这里输入内容";
    self.bodyView = contentArea;
    contentArea.delegate = self;
    
    UILabel* placeholderLabel = AWCreateLabel(CGRectMake(15, 10, contentArea.width, 30),
                                             @"输入内容",
                                             NSTextAlignmentLeft,
                                             nil,
                                             AWColorFromRGB(201, 201, 201));
    [self.contentView addSubview:placeholderLabel];
    self.textViewPlaceholder = placeholderLabel;
    
    UITextField* authField = [[UITextField alloc] initWithFrame:CGRectMake(contentArea.left,
                                                                           contentArea.bottom + 10,
                                                                           contentArea.width,
                                                                           37)];
    [self.contentView addSubview:authField];
    authField.placeholder = @"联系方式";
    authField.backgroundColor = [UIColor whiteColor];
    
    self.authorField = authField;
    
    self.navBar.rightItem = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
                                               @"提交",
                                               [UIColor whiteColor],
                                               self,
                                               @selector(send));
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.textViewPlaceholder.hidden = [textView.text length] > 0;
}

- (void)send
{
    if ( [self.bodyView.text length] == 0 ) {
        [[Toast showText:@"反馈内容不能为空"] setBackgroundColor:NAV_BAR_BG_COLOR];
        return;
    }
    
    [self.authorField resignFirstResponder];
    [self.bodyView resignFirstResponder];
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    if ( !self.apiManager ) {
        self.apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.apiManager sendRequest:APIRequestCreate(API_SEND_FEEDBACK, RequestMethodPost, @{ @"content": self.bodyView.text,
                                                                                           @"author": self.authorField.text})];
}

- (void)apiManagerDidSuccess:(APIManager *)manager
{
    [MBProgressHUD hideHUDForView:self.contentView animated:YES];
    
    [[Toast showText:@"提交成功！"] setBackgroundColor:NAV_BAR_BG_COLOR];
    
    self.bodyView.text = @"";
    self.authorField.text = @"";
}

- (void)apiManagerDidFailure:(APIManager *)manager
{
    [MBProgressHUD hideHUDForView:self.contentView animated:YES];
    
    [[Toast showText:@"提交失败！"] setBackgroundColor:NAV_BAR_BG_COLOR];
}

@end
