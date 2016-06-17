//
//  SmallToolbar.m
//  zgnx
//
//  Created by tangwei1 on 16/6/3.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "SmallToolbar.h"
#import "Defines.h"

@interface SmallToolbar ()

@property (nonatomic, strong) UIButton* bilibiliButton;
@property (nonatomic, strong) UIButton* favoriteButton;
@property (nonatomic, strong) UIButton* likeButton;
@property (nonatomic, strong) UILabel*  titleLabel;

@end
@implementation SmallToolbar

- (instancetype)initWithStream:(Stream *)aStream
{
    if ( self = [super init] ) {
        [self setup];
        self.stream = aStream;
    }
    return self;
}

- (void)setup
{
    self.frame = CGRectMake(0, 0, AWFullScreenWidth(), 50);
    self.backgroundColor = [UIColor whiteColor];
    
    self.bilibiliButton = AWCreateImageButton(@"btn_bili_close.png", self, @selector(openOrCloseBilibili:));
    [self.bilibiliButton setImage:[UIImage imageNamed:@"btn_bili_open.png"] forState:UIControlStateSelected];
    self.bilibiliButton.selected = YES;
    [self addSubview:self.bilibiliButton];
    self.bilibiliButton.tag = ToolbarButtonTagBili;
    
    self.favoriteButton = AWCreateImageButton(@"btn_favorite.png", self, @selector(favorite:));
    [self.favoriteButton setImage:[UIImage imageNamed:@"btn_favorited.png"] forState:UIControlStateSelected];
    [self addSubview:self.favoriteButton];
    self.favoriteButton.tag = ToolbarButtonTagFavorite;
    
    self.likeButton = AWCreateImageButton(@"tags_zan_n.png", self, @selector(like:));
    [self.likeButton setImage:[UIImage imageNamed:@"tags_zan_y.png"] forState:UIControlStateSelected];
    [self addSubview:self.likeButton];
    self.likeButton.tag = ToolbarButtonTagLike;
    
    self.titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    nil,
                                    nil);
    [self addSubview:self.titleLabel];
    
    UIView *line = AWCreateLine(CGSizeMake(self.width, 1),
                                AWColorFromRGB(231,231,231));
    [self addSubview:line];
    line.position = CGPointMake(0, self.height - 1);
}

- (void)setStream:(Stream *)stream
{
    _stream = stream;
    
    self.likeButton.selected = [stream.liked boolValue];
    self.favoriteButton.selected = [stream.favorited boolValue];
    
    self.titleLabel.text = stream.title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = 15;
    
    self.favoriteButton.position = CGPointMake(self.width - margin
                                               - self.favoriteButton.width,
                                               self.height / 2 -
                                               self.favoriteButton.height / 2);
    self.likeButton.position = CGPointMake(self.favoriteButton.left - margin
                                           - self.likeButton.width,
                                           self.height / 2 - self.likeButton.height / 2);
    self.bilibiliButton.position = CGPointMake(self.likeButton.left - margin -
                                               self.bilibiliButton.width,
                                               self.height / 2 -
                                               self.bilibiliButton.height / 2);
    self.titleLabel.frame = CGRectMake(margin,
                                       0,
                                       self.bilibiliButton.left - margin * 2,
                                       self.height);
}

- (void)favorite:(UIButton *)sender
{
    if ( self.toolbarButtonDidTapBlock ) {
        self.toolbarButtonDidTapBlock(self.favoriteButton);
    }
}

- (void)like:(UIButton *)sender
{
    if ( self.toolbarButtonDidTapBlock ) {
        self.toolbarButtonDidTapBlock(sender);
    }
}

- (void)openOrCloseBilibili:(UIButton *)sender
{
    if ( self.toolbarButtonDidTapBlock ) {
        self.toolbarButtonDidTapBlock(sender);
    }
}

@end
