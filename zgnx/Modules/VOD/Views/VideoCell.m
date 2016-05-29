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

@property (nonatomic, strong, readonly) UILabel* titleLabel;
@property (nonatomic, strong, readonly) UILabel* viewCountLabel;
@property (nonatomic, strong, readonly) UIImageView* coverImageView;
@property (nonatomic, strong, readonly) UILabel* dateLabel;
@property (nonatomic, strong, readonly) UILabel* likesCountLabel;

@property (nonatomic, strong) UIView*        digitToolbar;
@property (nonatomic, strong) StaticToolbar* staticToolbar;

@property (nonatomic, strong, readwrite) id cellData;

@end

@implementation VideoCell

@synthesize titleLabel      = _titleLabel;
@synthesize viewCountLabel  = _viewCountLabel;
@synthesize coverImageView  = _coverImageView;
@synthesize dateLabel       = _dateLabel;
@synthesize likesCountLabel = _likesCountLabel;

static CGFloat const kThumbLeft = 10;
static CGFloat const kThumbTop  = kThumbLeft;
static CGFloat const kBlackToolbarAlpha = 0.8;

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
    
    self.staticToolbar = [[StaticToolbar alloc] initWithViewCount:[data[@"view_count"] integerValue]
                                                       likesCount:[data[@"likes_count"] integerValue]
                                                        biliCount:0];
    
    self.titleLabel.text = data[@"title"];
//    self.viewCountLabel.text = [data[@"view_count"] description];
//    self.dateLabel.text = data[@"created_on"];
    
    self.coverImageView.image = nil;
    self.coverImageView.userInteractionEnabled = NO;
    self.coverImageView.backgroundColor = [UIColor lightTextColor];
    
    __weak typeof(self) weakSelf = self;
    [self.coverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:
                                                 [NSURL URLWithString:data[@"cover_image"]]]
                               placeholderImage:nil
                                        success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                            weakSelf.coverImageView.image = image;
                                            weakSelf.coverImageView.userInteractionEnabled = YES;
                                        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                            
                                        }];
}

- (void)dealloc
{
    _titleLabel     = nil;
    _viewCountLabel = nil;
    _coverImageView = nil;
    _dateLabel      = nil;
    _likesCountLabel = nil;
    
    self.digitToolbar = nil;
    self.staticToolbar = nil;
    
    self.cellData   = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.coverImageView.frame = [[self class] calcuThumbImageFrame];
    
    self.titleLabel.frame = CGRectMake(0, 0, self.coverImageView.width, 30);
    
    self.digitToolbar.frame = self.staticToolbar.frame =
    CGRectMake(0, self.coverImageView.height - 30,
               self.coverImageView.width, 30);
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero, nil, NSTextAlignmentCenter,
                                    nil,
                                    [UIColor whiteColor]);
        _titleLabel.backgroundColor = AWColorFromRGBA(0, 0, 0, kBlackToolbarAlpha);
        [self.coverImageView addSubview:_titleLabel];
    }
    return _titleLabel;
}

+ (CGRect)calcuThumbImageFrame
{
    static CGRect frame;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        frame = CGRectMake(kThumbLeft, kThumbTop,
                           AWFullScreenWidth() - kThumbLeft * 2,
                           (AWFullScreenWidth() - kThumbLeft * 2) * 0.618 );
    });
    return frame;
}

+ (CGFloat)cellHeight
{
    return CGRectGetMaxY([self calcuThumbImageFrame]);
}

- (UIImageView *)coverImageView
{
    if ( !_coverImageView ) {
        _coverImageView = AWCreateImageView(nil);
        _coverImageView.userInteractionEnabled = NO;
        _coverImageView.backgroundColor = AWColorFromRGB(137, 137, 137);
        [_coverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
        [self.contentView addSubview:_coverImageView];
        
        self.digitToolbar = [[UIView alloc] init];
        [_coverImageView addSubview:self.digitToolbar];
        self.digitToolbar.backgroundColor = AWColorFromRGBA(0, 0, 0, kBlackToolbarAlpha);
        
        [_coverImageView addSubview:self.staticToolbar];
    }
    return _coverImageView;
}

- (void)tap
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoCellDidSelectNotification object:self];
}

@end
