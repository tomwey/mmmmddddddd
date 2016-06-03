//
//  ButtonGroup.m
//  zgnx
//
//  Created by tangwei1 on 16/6/3.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "ButtonGroup.h"
#import <AWUITools/AWUITools.h>
#import <AWGeometry/UIView+AWGeometry.h>

@interface ButtonGroup ()

@property (nonatomic, strong) UIScrollView *buttonsContainer;

@property (nonatomic, weak) UIButton* lastButton;

@end
@implementation ButtonGroup

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame
            buttonNormalImages:nil
          buttonSelectedImages:nil];
}

- (instancetype)initWithFrame:(CGRect)frame buttonNormalImages:(NSArray<NSString *> *)normalImages
         buttonSelectedImages:(NSArray<NSString *> *)selectedImages
{
    if ( self = [super initWithFrame:frame] ) {
        
        self.buttonsContainer = [[UIScrollView alloc] init];
        [self addSubview:self.buttonsContainer];
        self.buttonsContainer.showsHorizontalScrollIndicator = NO;
        
        self.buttonNormalImages = normalImages;
        self.buttonSelectedImages = selectedImages;
        
        self.selectedIndex = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.buttonsContainer.frame = self.bounds;
    
    CGFloat left = 0;
    for (NSInteger index = 0; index < [self.buttonNormalImages count]; index ++) {
        UIButton* btn = (UIButton *)[self.buttonsContainer viewWithTag:100 + index];
        if ( !btn ) {
            btn = AWCreateImageButton(self.buttonNormalImages[index], self, @selector(btnClicked:));
            btn.tag = 100 + index;
            
            if ( index < [self.buttonSelectedImages count] ) {
                [btn setImage:[UIImage imageNamed:self.buttonSelectedImages[index]] forState:UIControlStateSelected];
            }
            
            [self.buttonsContainer addSubview:btn];
        }
        btn.position = CGPointMake(left, self.height / 2 - btn.height / 2);
        left = btn.right;
        
        if ( index == self.selectedIndex ) {
            btn.selected = YES;
        }
    }
    
    self.buttonsContainer.contentSize = CGSizeMake(left, self.height);
}

- (void)btnClicked:(UIButton *)sender
{
    self.selectedIndex = [sender tag] - 100;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    if ( [self.buttonNormalImages count] == 0 ) return;
    
    UIButton *currentBtn = [self.buttonsContainer viewWithTag:100 + selectedIndex];
    if ( currentBtn == self.lastButton ) {
        return;
    }
    
    self.lastButton.selected = NO;
    currentBtn.selected      = YES;
    self.lastButton = currentBtn;
    
    _selectedIndex = selectedIndex;
    
    [self.buttonsContainer scrollRectToVisible:currentBtn.frame animated:animated];
    
    if ( self.didSelectItemBlock ) {
        self.didSelectItemBlock(self);
    }
}

@end
