//
//  GrantView.m
//  zgnx
//
//  Created by tomwey on 6/17/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "GrantView.h"
#import "Defines.h"

@interface GrantView () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UITextField *moneyField;
@property (nonatomic, strong) UITextField *payPasswordField;

@property (nonatomic, strong) UIButton    *payButton;
@property (nonatomic, strong) UIButton    *cancelButton;

@property (nonatomic, strong) UIButton    *dotButton;

@end
@implementation GrantView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        
        self.frame = AWFullScreenBounds();
        
        self.maskView = [[UIView alloc] init];
        [self addSubview:self.maskView];
        self.maskView.backgroundColor = [UIColor blackColor];
        self.maskView.frame = self.bounds;
        self.maskView.alpha = 0.0;
        
        self.contentView = [[UIView alloc] init];
        [self addSubview:self.contentView];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.frame = CGRectMake(0, 0, self.width * 0.8, 190);
        
        self.contentView.layer.cornerRadius = 6;
        self.contentView.clipsToBounds = YES;
        
        
        self.moneyField = [[CustomTextField alloc] init];
        [self.contentView addSubview:self.moneyField];
        self.moneyField.placeholder = @"输入金额";
        self.moneyField.keyboardType = UIKeyboardTypeDecimalPad;
        
        self.moneyField.layer.cornerRadius = 0;
        self.moneyField.backgroundColor = [UIColor whiteColor];
        
        self.moneyField.layer.borderWidth = 1;
        self.moneyField.layer.borderColor = [BG_COLOR_GRAY CGColor];
        
        self.moneyField.frame = CGRectMake(20, 20, self.contentView.width - 40, 40);
        
        self.moneyField.delegate = self;

        // 支付密码
        self.payPasswordField = [[CustomTextField alloc] init];
        [self.contentView addSubview:self.payPasswordField];
        self.payPasswordField.placeholder = @"支付密码";
        self.payPasswordField.secureTextEntry = YES;
        
        self.payPasswordField.layer.cornerRadius = 0;
        self.payPasswordField.backgroundColor = [UIColor whiteColor];
        
        self.payPasswordField.layer.borderWidth = 1;
        self.payPasswordField.layer.borderColor = [BG_COLOR_GRAY CGColor];
        
        self.payPasswordField.frame = self.moneyField.frame;
        
        self.payPasswordField.top = self.moneyField.bottom + 15;
        
        self.cancelButton = AWCreateImageButton(nil, self, @selector(cancel));
        [self.contentView addSubview:self.cancelButton];
        [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:NAV_BAR_BG_COLOR forState:UIControlStateNormal];
        self.cancelButton.backgroundColor = [UIColor whiteColor];
        self.cancelButton.layer.borderColor = [NAV_BAR_BG_COLOR CGColor];
        self.cancelButton.layer.borderWidth = 1;
        
        self.cancelButton.frame = CGRectMake(20,
                                          self.payPasswordField.bottom + 15,
                                          (self.contentView.width - 55) / 2, 40);
        
        self.payButton = AWCreateImageButton(nil, self, @selector(pay));
        [self.contentView addSubview:self.payButton];
        [self.payButton setTitle:@"确定" forState:UIControlStateNormal];
        [self.payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.payButton.backgroundColor = NAV_BAR_BG_COLOR;
        
        self.payButton.frame = self.cancelButton.frame;
        self.payButton.left = self.cancelButton.right + 15;
    
    }
    return self;
}

- (BOOL)            textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string
{
    if ( [string isEqualToString:@""] ) {
        return YES;
    }
    
    if ( [string isEqualToString:@"."] &&
        [self.moneyField.text rangeOfString:@"."].location != NSNotFound ) {
        return NO;
    }
    
    if ( [self.moneyField.text length] == 0 && [string isEqualToString:@"."] ) {
        return NO;
    }
    
    if ( [self.moneyField.text length] == 1 && [self.moneyField.text isEqualToString:@"0"] && [string isEqualToString:@"."] == NO ) {
        return NO;
    }
    
    return YES;
}

- (void)showInView:(UIView *)view
{
    if ( self.superview == nil ) {
        [view addSubview:self];
    }
    
    [view bringSubviewToFront:self];
    
    self.contentView.center = CGPointMake(self.width / 2,
                                          -self.contentView.height / 2);
    
    [self.moneyField becomeFirstResponder];

    [UIView animateWithDuration:.25 animations:^{
        self.maskView.alpha = 0.6;
        self.contentView.center = CGPointMake(self.width / 2,
                                              self.contentView.height / 2 + 30);
    }];
}

- (void)pay
{
    if ( self.didPayBlock ) {
        self.didPayBlock([self.moneyField.text floatValue],
                         self.payPasswordField.text);
    }
}

- (void)dismiss
{
    [self cancel];
}

- (void)cancel
{
    [self.moneyField resignFirstResponder];
    [self.payPasswordField resignFirstResponder];
    
    [self.dotButton removeFromSuperview];
    self.dotButton = nil;
    
    [UIView animateWithDuration:.25 animations:^{
        self.maskView.alpha = 0.0;
        self.contentView.center = CGPointMake(self.width / 2,
                                              -self.contentView.height / 2);
    } completion:^(BOOL finished) {
        if ( self.didCancelBlock ) {
            self.didCancelBlock();
        }
        [self removeFromSuperview];
    }];
}

@end
