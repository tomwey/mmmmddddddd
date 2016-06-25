//
//  BiliInputControl.m
//  zgnx
//
//  Created by tomwey on 6/25/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "BiliInputControl.h"
#import "Defines.h"

@interface BiliInputControl () <UITextFieldDelegate>

@property (nonatomic, strong) CustomTextField *biliField;
@property (nonatomic, strong) UIButton        *sendButton;

@end
@implementation BiliInputControl

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.frame = CGRectMake(0, 0, AWFullScreenWidth(), 50);
        self.backgroundColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)noti
{
    CGRect frame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.top = self.superview.height - CGRectGetHeight(frame) - self.height + 1;
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    NSTimeInterval duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.top = self.superview.height - self.height;
    }];
}

- (void)hideKeyboard
{
    [self.biliField resignFirstResponder];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.biliField.frame = CGRectMake(10, self.height / 2 - 34/2,
                                      self.width - self.sendButton.width - 30, 34);

    self.sendButton.position = CGPointMake(self.width - self.sendButton.width - 10,
                                           self.biliField.midY - self.sendButton.height / 2);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.biliField resignFirstResponder];
    
    [self send];
    
    return YES;
}

- (CustomTextField *)biliField
{
    if ( !_biliField ) {
        _biliField = [[CustomTextField alloc] init];
        [self addSubview:_biliField];
        _biliField.returnKeyType = UIReturnKeyDone;
        _biliField.autocorrectionType = UITextAutocorrectionTypeNo;
        _biliField.placeholder = @"说两句...";
        _biliField.delegate = self;
    }
    return _biliField;
}

- (UIButton *)sendButton
{
    if ( !_sendButton ) {
        _sendButton = AWCreateImageButton(@"btn_send.png", self, @selector(send));
        [self addSubview:_sendButton];
    }
    return _sendButton;
}

- (void)send
{
    NSString *msg = [self.biliField.text stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ( [msg length] == 0 ) {
        return;
    }
    
    [self.biliField resignFirstResponder];
    self.biliField.text = @"";
    
    if ( self.didSendMessageBlock ) {
        self.didSendMessageBlock(msg);
    }
}

@end
