//
//  GrantTableHeaderView.m
//  zgnx
//
//  Created by tangwei1 on 16/6/13.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "GrantTableHeaderView.h"
#import "Defines.h"

@interface GrantTableHeaderView ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *moneyLabel;

@end

@implementation GrantTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(0, 0, AWFullScreenWidth(), 190);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.center = CGPointMake(self.width / 2, 15 + self.avatarView.height / 2);
    
    self.titleLabel.frame  = CGRectMake(0, self.avatarView.bottom + 15, self.width, 40);
    
    self.moneyLabel.frame  = CGRectMake(0, self.titleLabel.bottom + 5, self.width, 40);
}

- (void)setUser:(User *)aUser
{
    [self.avatarView setImageWithURL:[NSURL URLWithString:aUser.avatarUrl]
                    placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    
    NSString *tip = nil;
    CGFloat money = 0.0;
    if ( self.grantType == GrantTypeSent ) {
        tip = @"共打赏别人";
        money = [aUser.sentMoney floatValue];
    } else {
        tip = @"共收到打赏";
        money = [aUser.receiptMoney floatValue];
    }
    
    NSString *nickname = aUser.nickname ?: [aUser.mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4)
                                                                                 withString:@"****"];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:
                                         [NSString stringWithFormat:@"%@%@", nickname, tip]];
    [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(16, NO) } range:NSMakeRange(nickname.length,
                                                                                                   string.string.length - nickname.length)];
    self.titleLabel.attributedText = string;

    // 设置钱
    NSMutableAttributedString *moneyString = [[NSMutableAttributedString alloc] initWithString:
                                              [NSString stringWithFormat:@"%.2f元", money]];
    [moneyString addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(30, YES) }
                         range:NSMakeRange(0, moneyString.string.length - 1)];
    self.moneyLabel.attributedText = moneyString;
}

- (UIImageView *)avatarView
{
    if ( !_avatarView ) {
        _avatarView = AWCreateImageView(nil);
        [self addSubview:_avatarView];
        _avatarView.frame = CGRectMake(0, 0, 60, 60);
        
        _avatarView.layer.cornerRadius = _avatarView.height / 2;
        _avatarView.clipsToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    nil,
                                    [UIColor blackColor]);
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)moneyLabel
{
    if ( !_moneyLabel ) {
        _moneyLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    nil,
                                    [UIColor blackColor]);
        [self addSubview:_moneyLabel];
    }
    return _moneyLabel;
}

@end
