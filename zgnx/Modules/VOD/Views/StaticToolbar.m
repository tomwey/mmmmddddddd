//
//  StaticToolbar.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "StaticToolbar.h"
#import "Defines.h"

@implementation StaticToolbar
{
    __weak UIImageView* _iconView1;
    __weak UIImageView* _iconView2;
    __weak UIImageView* _iconView3;
    
    __weak UILabel* _viewCountLabel;
    __weak UILabel* _likeCountLabel;
    __weak UILabel* _biliCountLabel;
}

- (instancetype)initWithViewCount:(NSInteger)viewCount
                       likesCount:(NSInteger)likesCount
                        biliCount:(NSInteger)biliCount
{
    if ( self = [super init] ) {
        
        UIImageView* iconView1 = AWCreateImageView(@"tags_play.png");
        [self addSubview:iconView1];
        
        _iconView1 = iconView1;
        
        UILabel* viewCountLabel =
        AWCreateLabel(CGRectZero,
                      [@(viewCount) description],
                      NSTextAlignmentLeft,
                      nil,
                      [UIColor whiteColor]);
        [self addSubview:viewCountLabel];
        _viewCountLabel = viewCountLabel;
        
        UIImageView* iconView2 = AWCreateImageView(@"tags_collection.png");
        [self addSubview:iconView2];
        _iconView2 = iconView2;
        
        UILabel* likeCountLabel =
        AWCreateLabel(CGRectZero,
                      [@(likesCount) description],
                      NSTextAlignmentCenter,
                      nil,
                      [UIColor whiteColor]);
        [self addSubview:likeCountLabel];
        _likeCountLabel = likeCountLabel;
        
        UIImageView* iconView3 = AWCreateImageView(@"tags_comment.png");
        [self addSubview:iconView3];
        _iconView3 = iconView3;
        
        UILabel* biliCountLabel =
        AWCreateLabel(CGRectZero,
                      [@(biliCount) description],
                      NSTextAlignmentLeft,
                      nil,
                      [UIColor whiteColor]);
        [self addSubview:biliCountLabel];
        _biliCountLabel = biliCountLabel;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _iconView1.center = CGPointMake(5 + _iconView1.width/2,
                                    self.height / 2);
    
    CGSize size1 = [_viewCountLabel.text sizeWithAttributes:@{ NSFontAttributeName:_viewCountLabel.font }];
    
    _viewCountLabel.frame = CGRectMake(_iconView1.right + 5,
                                       _iconView1.top,
                                       size1.width, size1.height);
    _viewCountLabel.center = CGPointMake(_iconView1.right + 5 + _viewCountLabel.width / 2,
                                         self.height / 2);
    
    _likeCountLabel.frame = CGRectMake(0, 0, 150, 30);
    _likeCountLabel.center = CGPointMake(self.width/2, self.height/2);
    
    CGSize sizee = [_likeCountLabel.text sizeWithAttributes:@{ NSFontAttributeName:_likeCountLabel.font }];
    
    _iconView2.center = CGPointMake(_likeCountLabel.midX - sizee.width / 2 - 5 -
                                    _iconView2.width / 2,
                                    self.height/2);
    
    
    CGSize size = [_biliCountLabel.text  sizeWithAttributes:@{ NSFontAttributeName: _biliCountLabel.font }];
    _biliCountLabel.frame = CGRectMake(self.width - _iconView1.left - size.width,
                                       self.height / 2 - size.height / 2,
                                       size.width,
                                       size.height);
    
    
    _iconView3.center = CGPointMake(_biliCountLabel.left - _iconView3.width,
                                    self.height / 2);
}

@end
