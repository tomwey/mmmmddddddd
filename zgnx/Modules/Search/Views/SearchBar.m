//
//  SearchBar.m
//  zgnx
//
//  Created by tangwei1 on 16/6/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "SearchBar.h"
#import "Defines.h"

@interface SearchBar () <UITextFieldDelegate>

@property (nonatomic, strong) CustomTextField* searchTextField;

@end
@implementation SearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.frame = CGRectMake(0, 0, AWFullScreenWidth(), 44);
    self.backgroundColor = [UIColor whiteColor];
    
    self.searchTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(15, 5, self.width - 30, 34)];
    [self addSubview:self.searchTextField];
    self.searchTextField.placeholder = @"输入视频标题或简介";
    
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.searchTextField.delegate = self;
    [self.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
//    self.searchTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    
    self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)resignFirstResponder
{
    [self.searchTextField resignFirstResponder];
}

- (void)setText:(NSString *)text
{
    self.searchTextField.text = text;
}

- (NSString *)text {  return self.searchTextField.text; }

- (void)textFieldDidChange:(UITextField *)textField
{
    if ( [self.delegate respondsToSelector:@selector(searchBar:textDidChange:)] ) {
        [self.delegate searchBar:self textDidChange:textField.text];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ( [self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)] ) {
        return [self.delegate searchBarShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ( [self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)] ) {
        return [self.delegate searchBarShouldEndEditing:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchTextField resignFirstResponder];
    if ( [self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)] ) {
        return [self.delegate searchBarShouldReturn:self];
    }
    return YES;
}

@end
