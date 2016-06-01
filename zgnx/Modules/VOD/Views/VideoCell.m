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
#import "StaticToolbar.h"

NSString * const kVideoCellDidSelectNotification = @"kVideoCellDidSelectNotification";

@interface VideoCell ()

@property (nonatomic, strong) UIView*      containerView;
@property (nonatomic, strong) UILabel*     titleLabel;
@property (nonatomic, strong) UIImageView* coverImageView;

@property (nonatomic, strong) UIImageView* playIconView;
@property (nonatomic, strong) UILabel*     viewCountLabel;

@property (nonatomic, strong) UIImageView* msgIconView;
@property (nonatomic, strong) UILabel*     msgCountLabel;

@property (nonatomic, strong, readwrite) id cellData;

@end

@implementation VideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configData:(id)data
{
    self.cellData = data;
    
    self.titleLabel.text = data[@"title"];

    self.coverImageView.image = nil;
    self.coverImageView.userInteractionEnabled = NO;
    self.coverImageView.backgroundColor = [UIColor grayColor];
    
    __weak typeof(self) weakSelf = self;
    [self.coverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:
                                                 [NSURL URLWithString:data[@"cover_image"]]]
                               placeholderImage:nil
                                        success:
     ^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        weakSelf.coverImageView.image = image;
        weakSelf.coverImageView.userInteractionEnabled = YES;
    } failure:
     ^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                            
    }];
    
    self.viewCountLabel.text = [data[@"view_count"] description];
    self.msgCountLabel.text  = [data[@"msg_count"] description];
}

- (void)dealloc
{
    self.cellData   = nil;
    self.didSelectItem = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.containerView.frame = [[self class] calcuContainerViewFrame];
    
    self.titleLabel.frame = CGRectMake(10, 0, self.containerView.width - 20, 30);
    
    self.coverImageView.frame = CGRectInset(self.containerView.bounds, 0, 30);
    
    self.playIconView.center = CGPointMake(10 + self.playIconView.width/2,
                                           self.coverImageView.bottom + 15);
    self.viewCountLabel.frame = CGRectMake(self.playIconView.right + 5,
                                           self.coverImageView.bottom,
                                           self.containerView.width / 2 - self.playIconView.width - 5,
                                           30);
    CGSize size = [self.msgCountLabel.text sizeWithAttributes:@{ NSFontAttributeName: self.msgCountLabel.font }];
    self.msgCountLabel.frame = CGRectMake(self.containerView.width -
                                          self.playIconView.left - size.width,
                                          self.viewCountLabel.top,
                                          size.width,
                                          30);
    self.msgIconView.center = CGPointMake(self.msgCountLabel.left - 5
                                          - self.msgIconView.width/2,
                                          self.msgCountLabel.midY);
}

+ (CGRect)calcuContainerViewFrame
{
    static CGRect frame;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        frame = CGRectMake(kThumbLeft, kThumbTop,
                           AWFullScreenWidth() - kThumbLeft * 2,
                           (AWFullScreenWidth() - kThumbLeft * 2) * 0.618 + 60 );
    });
    return frame;
}

+ (CGFloat)cellHeight
{
    return CGRectGetMaxY([self calcuContainerViewFrame]);
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

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero, nil, NSTextAlignmentLeft,
                                    AWSystemFontWithSize(15, NO),
                                    [UIColor blackColor]);
        _titleLabel.backgroundColor = [UIColor whiteColor];
        [self.containerView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)coverImageView
{
    if ( !_coverImageView ) {
        _coverImageView = AWCreateImageView(nil);
        _coverImageView.userInteractionEnabled = NO;
        _coverImageView.backgroundColor = [UIColor grayColor];//AWColorFromRGB(137, 137, 137);
        [_coverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
        [self.containerView addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (UIImageView *)playIconView
{
    if ( !_playIconView ) {
        _playIconView = AWCreateImageView(@"tags_play.png");
        _playIconView.backgroundColor = [UIColor grayColor];
        [self.containerView addSubview:_playIconView];
    }
    return _playIconView;
}

- (UILabel *)viewCountLabel
{
    if ( !_viewCountLabel ) {
        _viewCountLabel = AWCreateLabel(CGRectZero, nil, NSTextAlignmentLeft,
                                    nil,
                                    [UIColor grayColor]);
        _viewCountLabel.backgroundColor = [UIColor whiteColor];
        [self.containerView addSubview:_viewCountLabel];
    }
    return _viewCountLabel;
}

- (UIImageView *)msgIconView
{
    if ( !_msgIconView ) {
        _msgIconView = AWCreateImageView(@"tags_comment.png");
        _msgIconView.backgroundColor = [UIColor grayColor];
        [self.containerView addSubview:_msgIconView];
    }
    return _msgIconView;
}

- (UILabel *)msgCountLabel
{
    if ( !_msgCountLabel ) {
        _msgCountLabel = AWCreateLabel(CGRectZero, nil, NSTextAlignmentLeft,
                                        nil,
                                        [UIColor grayColor]);
        _msgCountLabel.backgroundColor = [UIColor whiteColor];
        [self.containerView addSubview:_msgCountLabel];
    }
    return _msgCountLabel;
}

- (void)tap
{
    if ( self.didSelectItem ) {
        self.didSelectItem(self);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoCellDidSelectNotification object:self];
    }
}

@end
