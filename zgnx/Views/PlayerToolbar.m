//
//  PlayerToolbar.m
//  zgnx
//
//  Created by tangwei1 on 16/5/30.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "PlayerToolbar.h"
#import "Defines.h"

@interface PlayerToolbar ()

@property (nonatomic, strong) UIButton* leftButton;
@property (nonatomic, strong) UIButton* rightButton;

@end
@implementation PlayerToolbar
{
    UIView* _maskView;
}

- (instancetype)initWithLeftButtonImage:(NSString *)leftImageName
                       rightButtonImage:(NSString *)rightImageName
{
    if ( self = [super init] ) {
        
        _maskView = [[UIView alloc] init];
        [self addSubview:_maskView];
        _maskView.backgroundColor = AWColorFromRGBA(0, 0, 0, kBlackToolbarAlpha);
        
        self.leftButton = AWCreateImageButton(leftImageName, self, @selector(btnClicked:));
        [self addSubview:self.leftButton];
        
        self.rightButton = AWCreateImageButton(rightImageName, self, @selector(btnClicked:));
        [self addSubview:self.rightButton];
    }
    return self;
}

- (void)dealloc
{
    self.leftButtonClickBlock = nil;
    self.rightButtonClickBlock = nil;
}

- (void)btnClicked:(id)sender
{
    if ( self.leftButton == sender ) {
        if ( self.leftButtonClickBlock ) {
            self.leftButtonClickBlock(self, sender);
        }
    } else {
        if ( self.rightButtonClickBlock ) {
            self.rightButtonClickBlock(self, sender);
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _maskView.frame = self.bounds;
    
    CGFloat left = 10;
    self.leftButton.center = CGPointMake(left + self.leftButton.width / 2,
                                         self.height / 2);
    self.rightButton.center = CGPointMake(self.width - left - self.rightButton.width / 2, self.height / 2);
}

@end
