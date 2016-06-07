//
//  VideoPlayerView.h
//  zgnx
//
//  Created by tangwei1 on 16/6/3.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VideoPlayerType) {
    VideoPlayerTypeLiving = 1, // 直播播放器
    VideoPlayerTypeVOD    = 2, // 点播播放器
};

@interface VideoPlayer : UIView

- (instancetype)initWithContentURL:(NSURL *)contentURL;

/**
 播放器类型，默认为点播播放器，值为VideoPlayerVOD;
 */
@property (nonatomic, assign) VideoPlayerType playerType;

/**
 * 是否自动播放，默认为YES
 */
@property (nonatomic, assign) BOOL shouldAutoplay;

/**
 * 当前播放进度，只有推荐的点播视频才有观看历史
 */
@property (nonatomic, assign) NSTimeInterval currentPlaybackTime;

/**
 * 是否是全屏播放，这里的全屏只针对设备横竖屏来说的
 */
@property (nonatomic, assign) BOOL fullscreen;

@property (nonatomic, strong) NSArray<UIView *> * extraItemsInControl;

@property (nonatomic, copy) void (^didHideControlCallback)(VideoPlayer *player, BOOL hidden);
@property (nonatomic, copy) void (^didClickFullscreenCallback)(VideoPlayer *player);

/**
 * 动画的方式设置全屏
 */
//- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated;

- (void)finishPlaying;

@end
