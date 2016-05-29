//
//  UserProfileView.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "UserProfileView.h"
#import "Defines.h"
#import "UIImageView+AFNetworking.h"

@interface UserProfileView ()

@property (nonatomic, strong) UIImageView* avatarView;
@property (nonatomic, strong) UILabel* noLoginTipLabel;

@end
@implementation UserProfileView

- (instancetype)initWithUser:(User*)aUser
{
    if ( self = [super init] ) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
        
//        self.user = nil;
    }
    return self;
}

- (void)dealloc
{
    _user = nil;
    self.didClickBlock = nil;
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    self.frame = CGRectMake(0, 0, width, width * 0.382);
    
    self.avatarView = AWCreateImageView(nil);
    [self addSubview:self.avatarView];
    
    CGFloat avatarWidth, avatarHeight;
    avatarWidth = avatarHeight = self.height * 0.8;
    
    self.avatarView.frame = CGRectMake(0, 0, avatarWidth, avatarWidth);
    self.avatarView.center = CGPointMake(self.width / 2,
                                         self.height / 2);
    self.avatarView.backgroundColor = NAV_BAR_BG_COLOR;
    
    self.avatarView.layer.cornerRadius = avatarWidth / 2;
    self.avatarView.clipsToBounds = YES;
    
    self.avatarView.userInteractionEnabled = YES;
    
    [self.avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
}

- (void)tap
{
    if ( self.didClickBlock ) {
        self.didClickBlock(self);
//        self.didClickBlock = nil;
    }
}

- (void)setUser:(User *)user
{
    _user = user;
    
    BOOL logined = [[UserService sharedInstance] isLoginedForUser:_user];
    if ( logined ) {
        [self.noLoginTipLabel removeFromSuperview];
        self.noLoginTipLabel = nil;
        
        [self.avatarView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    } else {
        if ( !self.noLoginTipLabel ) {
            self.noLoginTipLabel =
            AWCreateLabel(CGRectMake(0, 0, self.avatarView.width, 30),
                nil,
                NSTextAlignmentCenter,
                nil,
                          [UIColor whiteColor]);
            self.noLoginTipLabel.center = self.avatarView.center;
            [self addSubview:self.noLoginTipLabel];
        }
        self.noLoginTipLabel.text = @"未登录";
        self.avatarView.image = nil;
    }
}

@end
