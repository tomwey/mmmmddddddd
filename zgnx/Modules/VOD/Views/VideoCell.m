//
//  VideoCell.m
//  zgnx
//
//  Created by tangwei1 on 16/5/26.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VideoCell.h"
#import "Defines.h"
#import <UIImageView+AFNetworking.h>

@interface VideoCell ()

@property (nonatomic, strong, readonly) UILabel* titleLabel;
@property (nonatomic, strong, readonly) UILabel* viewCountLabel;
@property (nonatomic, strong, readonly) UIImageView* coverImageView;
@property (nonatomic, strong, readonly) UILabel* dateLabel;

@end

@implementation VideoCell

@synthesize titleLabel = _titleLabel;
@synthesize viewCountLabel = _viewCountLabel;
@synthesize coverImageView = _coverImageView;
@synthesize dateLabel = _dateLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data
{
    self.titleLabel.text = data[@"title"];
    self.viewCountLabel.text = [data[@"view_count"] description];
    self.dateLabel.text = data[@"created_on"];
    
    self.coverImageView.image = nil;
    self.coverImageView.backgroundColor = [UIColor lightTextColor];
    [self.coverImageView setImageWithURL:[NSURL URLWithString:data[@"cover_image"]]];
}

- (void)dealloc
{
    _titleLabel     = nil;
    _viewCountLabel = nil;
    _coverImageView = nil;
    _dateLabel      = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(10, 5, 158, 30);
    
    self.viewCountLabel.frame = CGRectMake(self.width - 88 - self.titleLabel.left,
                                           self.titleLabel.top,
                                           88,
                                           self.titleLabel.height);
    self.coverImageView.frame = CGRectMake(self.titleLabel.left,
                                           self.titleLabel.bottom + 5,
                                           self.width - self.titleLabel.left * 2,
                                           ( self.width - self.titleLabel.left * 2 ) * 0.618);
    self.dateLabel.frame = CGRectMake(self.titleLabel.left,
                                      self.coverImageView.bottom + 5,
                                      200,
                                      30);
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero, nil, NSTextAlignmentLeft, nil, nil);
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)viewCountLabel
{
    if ( !_viewCountLabel ) {
        _viewCountLabel = AWCreateLabel(CGRectZero, nil, NSTextAlignmentRight, nil, nil);
        [self.contentView addSubview:_viewCountLabel];
    }
    return _viewCountLabel;
}

- (UILabel *)dateLabel
{
    if ( !_dateLabel ) {
        _dateLabel = AWCreateLabel(CGRectZero, nil, NSTextAlignmentLeft, nil, nil);
        [self.contentView addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UIImageView *)coverImageView
{
    if ( !_coverImageView ) {
        _coverImageView = AWCreateImageView(nil);
        [self.contentView addSubview:_coverImageView];
    }
    return _coverImageView;
}

@end
