//
//  GrantCell.m
//  zgnx
//
//  Created by tomwey on 6/12/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "GrantCell.h"

@interface GrantCell ()

@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *moneyLabel;

@end
@implementation GrantCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data
{
    self.nicknameLabel.text = data[@"user"][@"nickname"] ?:
    [data[@"user"][@"mobile"] stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    if ( [self.nicknameLabel.text length] == 0 ) {
        self.nicknameLabel.text = @"系统";
    }
    self.dateLabel.text = data[@"created_at"];
    self.moneyLabel.text = [NSString stringWithFormat:@"¥ %@",data[@"money"]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nicknameLabel.frame = CGRectMake(15, 0, (self.width - 30) * 0.6,
                                          30);
    self.dateLabel.frame = CGRectMake(self.nicknameLabel.left,
                                      self.nicknameLabel.bottom,
                                      self.nicknameLabel.width,
                                      30);
    self.moneyLabel.frame = CGRectMake(0,
                                       self.nicknameLabel.top,
                                       self.width - 30 - self.nicknameLabel.width, 30);
    self.moneyLabel.left = self.width - self.moneyLabel.width - self.nicknameLabel.left;
}

- (UILabel *)nicknameLabel
{
    if ( !_nicknameLabel ) {
        _nicknameLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       nil,
                                       nil);
        [self.contentView addSubview:_nicknameLabel];
    }
    return _nicknameLabel;
}

- (UILabel *)dateLabel
{
    if ( !_dateLabel ) {
        _dateLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       nil,
                                       nil);
        [self.contentView addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UILabel *)moneyLabel
{
    if ( !_moneyLabel ) {
        _moneyLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentRight,
                                       nil,
                                       nil);
        [self.contentView addSubview:_moneyLabel];
    }
    return _moneyLabel;
}

@end
