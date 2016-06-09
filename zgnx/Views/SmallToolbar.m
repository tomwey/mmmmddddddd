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
@property (nonatomic, strong) UIButton* shareButton;
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
    self.frame = CGRectMake(0, 0, AWFullScreenWidth(), 44);
    
    self.bilibiliButton = AWCreateImageButton(@"danmu.png", self, @selector(openOrCloseBilibili:));
    [self.bilibiliButton setImage:[UIImage imageNamed:@"danmu_h.png"] forState:UIControlStateSelected];
    self.bilibiliButton.selected = YES;
    [self addSubview:self.bilibiliButton];
    self.bilibiliButton.tag = ToolbarButtonTagBili;
    
    self.shareButton = AWCreateImageButton(@"btn_share.png", self, @selector(share));
    [self addSubview:self.shareButton];
    self.shareButton.tag = ToolbarButtonTagShare;
    
    self.likeButton = AWCreateImageButton(@"btn_like.png", self, @selector(like:));
    [self.likeButton setImage:[UIImage imageNamed:@"btn_liked.png"] forState:UIControlStateSelected];
    [self addSubview:self.likeButton];
    self.likeButton.tag = ToolbarButtonTagLike;
    
    self.titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    nil,
                                    nil);
    [self addSubview:self.titleLabel];
}

- (void)setStream:(Stream *)stream
{
    _stream = stream;
    
    if ( [stream.type integerValue] == 1 ) {
        self.likeButton.hidden = YES;
    } else {
        self.likeButton.hidden = NO;
        self.likeButton.selected = [stream.liked boolValue];
    }
    
    self.titleLabel.text = stream.title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = 15;
    if ( self.likeButton.hidden ) {
        self.shareButton.position = CGPointMake(self.width - margin - self.shareButton.width,
                                                self.height / 2 - self.shareButton.height / 2);
        self.bilibiliButton.position = CGPointMake(self.shareButton.left - margin - self.bilibiliButton.width,
                                                   self.height / 2 - self.bilibiliButton.height / 2);
        self.titleLabel.frame = CGRectMake(margin, self.height / 2 - 34 / 2,
                                           self.bilibiliButton.left - margin - margin, 34);
    } else {
        self.likeButton.position = CGPointMake(self.width - margin - self.likeButton.width,
                                               self.height / 2 - self.likeButton.height / 2);
        
        self.shareButton.position = CGPointMake(self.likeButton.left - margin - self.shareButton.width,
                                                self.height / 2 - self.shareButton.height / 2);
        self.bilibiliButton.position = CGPointMake(self.shareButton.left - margin - self.bilibiliButton.width,
                                                   self.height / 2 - self.bilibiliButton.height / 2);
        self.titleLabel.frame = CGRectMake(margin, self.height / 2 - 34 / 2,
                                           self.bilibiliButton.left - margin - margin, 34);
    }
}

- (void)share
{
    if ( self.toolbarButtonDidTapBlock ) {
        self.toolbarButtonDidTapBlock(self.shareButton);
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
