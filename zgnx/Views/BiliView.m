//
//  BiliView.m
//  zgnx
//
//  Created by tomwey on 6/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "BiliView.h"
#import "CustomTextField.h"

@interface BiliView ()

@property (nonatomic, strong) UIScrollView* biliContainerView;
@property (nonatomic, strong) CustomTextField* inputField;

@end
@implementation BiliView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

@end
