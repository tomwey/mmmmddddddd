//
//  LiveThumbView.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "LiveThumbView.h"
#import "Defines.h"
#import "UIImageView+AFNetworking.h"

@interface LiveThumbView ()

@property (nonatomic, strong) UIImageView* coverImageView;

@end

@implementation LiveThumbView
{
    UIView*      _blackToolbar;
    
    UILabel*     _dateLabel;
    UILabel*     _viewCountLabel;
    
    UIImageView* _playView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    self.didSelectBlock = nil;
}

- (void)setup
{
    self.coverImageView = AWCreateImageView(nil);
    self.coverImageView.frame = self.bounds;
    [self addSubview:self.coverImageView];
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.coverImageView.backgroundColor = AWColorFromRGB(137,137,137);
    
    _blackToolbar = [[UIView alloc] init];
    [self addSubview:_blackToolbar];
    _blackToolbar.backgroundColor = AWColorFromRGBA(0, 0, 0, kBlackToolbarAlpha);
    _blackToolbar.frame = CGRectMake(0, 0, 0, 30);
    
    _playView = AWCreateImageView(@"btn_play.png");
    [self addSubview:_playView];
    
    _dateLabel = AWCreateLabel(CGRectZero,
                               nil,
                               NSTextAlignmentLeft,
                               AWSystemFontWithSize(16, NO),
                               [UIColor whiteColor]);
    [self addSubview:_dateLabel];
    
    _viewCountLabel = AWCreateLabel(CGRectZero,
                               nil,
                               NSTextAlignmentRight,
                               AWSystemFontWithSize(16, NO),
                               [UIColor whiteColor]);
    [self addSubview:_viewCountLabel];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(tap)]];
}

- (void)tap
{
    if ( self.didSelectBlock ) {
        self.didSelectBlock(self);
        self.didSelectBlock = nil;
    }
}

- (void)setLiveInfo:(NSDictionary *)liveInfo
{
    _liveInfo = liveInfo;
    
    self.coverImageView.image = nil;
    [self.coverImageView setImageWithURL:[NSURL URLWithString:liveInfo[@"cover_image"]]];
    
    NSInteger type = [liveInfo[@"type"] integerValue];
    if ( type == 1 ) {
        NSString* dateStr = [[liveInfo[@"live_time"] componentsSeparatedByString:@" "] firstObject];
        _dateLabel.text = [dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    } else if ( type == 2 ) {
        _dateLabel.text = [liveInfo[@"created_on"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    _viewCountLabel.text = [NSString stringWithFormat:@"围观人数：%@",
                            liveInfo[@"view_count"]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _playView.center = CGPointMake(self.width / 2,
                                   self.height / 2);
    _blackToolbar.frame = CGRectMake(0, self.height - 30,
                                     self.width,
                                     30);
    
    _dateLabel.frame = CGRectMake(5, _blackToolbar.top,
                                  110,
                                  30);
    _viewCountLabel.frame = CGRectMake(self.width - 5 - 200,
                                       _blackToolbar.top,
                                       200, 30);
}

@end
