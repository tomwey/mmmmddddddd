//
//  BiliCell.m
//  zgnx
//
//  Created by tomwey on 6/11/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "BiliCell.h"
#import "Bilibili.h"

@interface BiliCell ()

@property (nonatomic, strong) Bilibili *currentBilibili;

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel     *nicknameLabel;
@property (nonatomic, strong) UILabel     *contentLabel;

@property (nonatomic, strong) UIView      *containerView;

@end

@implementation BiliCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
    }
    return self;
}

- (void)configData:(id)data
{
    if ( [data isKindOfClass:[Bilibili class]] ) {
        self.currentBilibili = data;
    } else if ( [data isKindOfClass:[NSDictionary class]] ) {
        self.currentBilibili = [[Bilibili alloc] initWithDictionary:data];
    }
    
    [self.avatarView setImageWithURL:
        [NSURL URLWithString:self.currentBilibili.avatarUrl]
                    placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    self.nicknameLabel.text = self.currentBilibili.nickname;
    self.contentLabel.text = self.currentBilibili.content;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.containerView.frame = CGRectMake(0, 0, self.width, 80);
    
    self.avatarView.position = CGPointMake(10, 10);
    self.nicknameLabel.frame = CGRectMake(self.avatarView.right + 5,
                                          self.avatarView.midY - 30 / 2.0,
                                          self.width - self.avatarView.right - 15, 37);
    self.contentLabel.frame = CGRectMake(self.avatarView.left,
                                         self.avatarView.bottom,
                                         self.width - self.avatarView.left * 2,
                                         30);
}

- (UIImageView *)avatarView
{
    if ( !_avatarView ) {
        _avatarView = AWCreateImageView(nil);
        [self.containerView addSubview:_avatarView];
        _avatarView.frame = CGRectMake(0, 0, 30, 30);
        _avatarView.layer.cornerRadius = _avatarView.height / 2.0;
        _avatarView.clipsToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)nicknameLabel
{
    if ( !_nicknameLabel ) {
        _nicknameLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       nil,
                                       [UIColor blackColor]);
        [self.containerView addSubview:_nicknameLabel];
    }
    return _nicknameLabel;
}

- (UILabel *)contentLabel
{
    if ( !_contentLabel ) {
        _contentLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       nil,
                                       [UIColor blackColor]);
        [self.containerView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UIView *)containerView
{
    if ( !_containerView ) {
        _containerView = [[UIView alloc] init];
        [self.contentView addSubview:_containerView];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}

@end
