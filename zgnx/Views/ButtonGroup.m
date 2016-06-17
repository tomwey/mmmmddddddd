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
#import "Defines.h"

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
        
        _selectedIndex = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.buttonsContainer.frame = self.bounds;
    
    CGFloat left = 0;
    NSArray *titles = @[@"弹幕", @"节目介绍", @"赏一个"];
    CGFloat width = self.width / 3;
    for (NSInteger index = 0; index < 2; index ++) {
        UIButton* btn = (UIButton *)[self.buttonsContainer viewWithTag:100 + index];
        if ( !btn ) {
            btn = AWCreateImageButton(nil, self, @selector(btnClicked:));
            btn.tag = 100 + index;
            btn.frame = CGRectMake(0, 0, width, self.height);
//            if ( index < [self.buttonSelectedImages count] ) {
//                [btn setImage:[UIImage imageNamed:self.buttonSelectedImages[index]] forState:UIControlStateSelected];
//            }
            [btn setTitle:titles[index] forState:UIControlStateNormal];
            if ( index < 2 ) {
                btn.backgroundColor = [UIColor whiteColor];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            } else {
                btn.backgroundColor = AWColorFromRGB(239,16,17);
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, btn.height - 2, btn.width, 2)];
            [btn addSubview:line];
            line.backgroundColor = AWColorFromRGB(181, 181, 181);
            line.tag = 1111;
            
            [self.buttonsContainer addSubview:btn];
        }
        btn.position = CGPointMake(left, self.height / 2 - btn.height / 2);
        left = btn.right;
        
        if ( index == self.selectedIndex ) {
            btn.selected = YES;
            self.lastButton = btn;
            UIView *line = [btn viewWithTag:1111];
            line.backgroundColor = AWColorFromRGB(252, 181, 3);
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
//    if ( [self.buttonNormalImages count] == 0 ) return;
    
    UIButton *currentBtn = [self.buttonsContainer viewWithTag:100 + selectedIndex];
    if ( currentBtn == self.lastButton ) {
        return;
    }
    
    self.lastButton.selected = NO;
    [[self.lastButton viewWithTag:1111] setBackgroundColor:AWColorFromRGB(181, 181, 181)];
    
    currentBtn.selected      = YES;
    [[currentBtn viewWithTag:1111] setBackgroundColor:AWColorFromRGB(252, 181, 3)];
    
    self.lastButton = currentBtn;
    
    _selectedIndex = selectedIndex;
    
    [self.buttonsContainer scrollRectToVisible:currentBtn.frame animated:animated];
    
    if ( self.didSelectItemBlock ) {
        self.didSelectItemBlock(self);
    }
}

@end
