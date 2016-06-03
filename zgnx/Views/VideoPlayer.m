//
//  VideoPlayerView.m
//  zgnx
//
//  Created by tangwei1 on 16/6/3.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Defines.h"

typedef NS_ENUM(NSInteger, SliderTouchState) {
    SliderTouchStateStartDrag,
    SliderTouchStateMoving,
    SliderTouchStateEndDrag,
};
@protocol VideoPlayerControlBarDelegate <NSObject>

@optional
- (void)playBtnDidClick;

- (void)fullscreenBtnDidClick;

- (void)sliderStateUpdate:(SliderTouchState)touchState;

@end
@interface VideoPlayerControlBar : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, strong, readonly) UILabel* timeLabel;
@property (nonatomic, strong, readonly) UISlider* progressSlider;

@property (nonatomic, assign) BOOL fullscreen;

@property (nonatomic, weak) id <VideoPlayerControlBarDelegate> delegate;

/**
 * 添加额外的组件，然后从全屏按钮的左边位置依次向左排布
 */
- (void)addExtraItem:(UIView *)item;
- (void)removeExtraItem:(UIView *)item;

- (void)addExtraItems:(NSArray<UIView *> *)items;
- (void)removeAllExtraItems;

@end

@interface VideoPlayer () <UIGestureRecognizerDelegate, VideoPlayerControlBarDelegate>

@property (nonatomic, strong) MPMoviePlayerController* player;
@property (nonatomic, strong) VideoPlayerControlBar* playerControl;
@property (nonatomic, strong) UIActivityIndicatorView* spinner;

@property (nonatomic, strong) NSTimer* autoHideTimer;
@property (nonatomic, strong) NSTimer* updateProgressTimer;

@end

@implementation VideoPlayer

- (instancetype)initWithContentURL:(NSURL *)contentURL
{
    if ( self = [super init] ) {
        self.player = [[MPMoviePlayerController alloc] initWithContentURL:contentURL];
        [self addSubview:self.player.view];
        
        self.player.controlStyle = MPMovieControlStyleNone;
        self.player.scalingMode  = MPMovieScalingModeAspectFit;
        self.player.fullscreen   = NO;
        
        self.playerControl = [[VideoPlayerControlBar alloc] init];
        [self addSubview:self.playerControl];
        
//        self.playerControl.backgroundColor = [UIColor redColor];
        
        self.shouldAutoplay = YES;
        self.playerType = VideoPlayerTypeVOD;
        
        self.playerControl.hidden = YES;
        self.playerControl.delegate = self;
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:self.spinner];
        self.spinner.hidesWhenStopped = YES;
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap)];
        tap.numberOfTapsRequired = 1;
        tap.delegate = self;
        [self.player.view addGestureRecognizer:tap];
        
        self.autoHideTimer = [NSTimer timerWithTimeInterval:5.0
                                                     target:self
                                                   selector:@selector(autoHideControl)
                                                   userInfo:nil
                                                    repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.autoHideTimer forMode:NSRunLoopCommonModes];
        [self.autoHideTimer setFireDate:[NSDate distantFuture]];
        
        self.updateProgressTimer = [NSTimer timerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateProgress)
                                                         userInfo:nil
                                                          repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.updateProgressTimer forMode:NSRunLoopCommonModes];
        [self.updateProgressTimer setFireDate:[NSDate distantFuture]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerLoadStateDidChange:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopPlaying)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
    }
    return self;
}

- (void)autoHideControl
{
    self.playerControl.hidden = YES;
    [self.autoHideTimer setFireDate:[NSDate distantFuture]];
    if ( self.didHideControlCallback ) {
        self.didHideControlCallback(self, YES);
    }
}

- (void)updateProgress
{
    [self.playerControl.progressSlider setValue: self.player.currentPlaybackTime / self.player.duration animated:YES];
    self.playerControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@",
                                         [self timeFromSeconds:self.player.currentPlaybackTime],
                                         [self timeFromSeconds:self.player.duration]];
}

#pragma mark - gesture delegate
// this allows you to dispatch touches
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)playerLoadStateDidChange:(NSNotification *)noti
{
    NSLog(@"state: %d, duration: %f, currentPlayback: %f", self.player.loadState, self.player.duration, self.player.currentPlaybackTime);
    if ( ( self.player.loadState & MPMovieLoadStatePlayable ) == MPMovieLoadStatePlayable ) {
        NSLog(@"视频可以播放");
        [self.spinner stopAnimating];
    } else if ( (self.player.loadState & MPMovieLoadStatePlaythroughOK) == MPMovieLoadStatePlaythroughOK ) {
        NSLog(@"开始播放");
        
        [self.spinner stopAnimating];
        [self startPlaying];
    } else if ( (self.player.loadState & MPMovieLoadStateStalled) == MPMovieLoadStateStalled ) {
        [self.spinner startAnimating];
    } else if ( (self.player.loadState & MPMovieLoadStateUnknown) == MPMovieLoadStateUnknown ) {
//        [[Toast showText:@"视频加载失败！"] setBackgroundColor: NAV_BAR_BG_COLOR];
    }
}

- (void)stopPlaying
{
    self.playerControl.playing = NO;
    
    [self.updateProgressTimer setFireDate:[NSDate distantFuture]];
    
    [self.playerControl.progressSlider setValue: 1.0 animated:YES];
    self.playerControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@",
                                         [self timeFromSeconds:self.player.duration],
                                         [self timeFromSeconds:self.player.duration]];
}

- (void)startPlaying
{
    self.playerControl.hidden = NO;
    self.playerControl.playing = YES;
    
    [self.autoHideTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    
    [self.updateProgressTimer setFireDate:[NSDate date]];
    self.playerControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@",
                                         [self timeFromSeconds:0],
                                         [self timeFromSeconds:self.player.duration]];
    
    [self.playerControl.progressSlider setValue:0.0 animated:YES];
    
    [self.playerControl setNeedsLayout];
}

- (void)resumePlay
{
    [self.player play];
    
    self.playerControl.playing = YES;
    [self.updateProgressTimer setFireDate:[NSDate date]];
}

- (void)pausePlay
{
    [self.player pause];
    
    self.playerControl.playing = NO;
    [self.updateProgressTimer setFireDate:[NSDate distantFuture]];
}

- (void)fullscreenBtnDidClick
{
    if ( self.didClickFullscreenCallback ) {
        self.didClickFullscreenCallback(self);
    }
}

- (void)playBtnDidClick
{
    if ( self.playerControl.playing ) {
        [self resumePlay];
    } else {
        [self pausePlay];
    }
}

- (void)sliderStateUpdate:(SliderTouchState)touchState
{
    switch (touchState) {
        case SliderTouchStateStartDrag:
        {
            [self.autoHideTimer setFireDate:[NSDate distantFuture]];
            [self.updateProgressTimer setFireDate:[NSDate distantFuture]];
        }
            break;
        case SliderTouchStateMoving:
        {
            double time = self.player.duration * self.playerControl.progressSlider.value;
            self.playerControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@",
                                                 [self timeFromSeconds:time],
                                                 [self timeFromSeconds:self.player.duration]];
        }
            break;
        case SliderTouchStateEndDrag:
        {
            NSTimeInterval currentTime = self.player.duration * self.playerControl.progressSlider.value;
//            if ( currentTime >= self.player.duration ) {
//                [self.player stop];
//            } else {
                self.player.currentPlaybackTime = currentTime;
                
                [self.autoHideTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
                
                [self.updateProgressTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
//            }
            
        }
            break;
            
        default:
            break;
    }
}

- (NSString *)timeFromSeconds:(NSTimeInterval)seconds
{
    NSInteger time = floor(seconds);
    NSInteger hh = time / 3600;
    NSInteger mm = (time / 60) % 60;
    NSInteger ss = time % 60;
    if(hh > 0)
        return  [NSString stringWithFormat:@"%d:%02i:%02i",hh,mm,ss];
    else
        return  [NSString stringWithFormat:@"%02i:%02i",mm,ss];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)doTap
{
    self.playerControl.hidden = !self.playerControl.hidden;
    if ( self.playerControl.hidden ) {
        [self.autoHideTimer setFireDate:[NSDate distantFuture]];
    } else {
        [self.autoHideTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
    if ( self.didHideControlCallback ) {
        self.didHideControlCallback(self, self.playerControl.hidden);
    }
}

- (void)setShouldAutoplay:(BOOL)shouldAutoplay
{
    _shouldAutoplay = shouldAutoplay;
    self.player.shouldAutoplay = shouldAutoplay;
    
    if ( shouldAutoplay ) {
        [self.spinner startAnimating];
    }
}

- (void)setPlayerType:(VideoPlayerType)playerType
{
    _playerType = playerType;
    switch (playerType) {
        case VideoPlayerTypeLiving:
        {
            self.playerControl.timeLabel.hidden = YES;
//            self.playerControl.progress = 0.0;
            self.playerControl.progressSlider.hidden = YES;
        }
            break;
        case VideoPlayerTypeVOD:
        {
            self.playerControl.timeLabel.hidden = NO;
            self.playerControl.progressSlider.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)setFullscreen:(BOOL)fullscreen
{
    _fullscreen = fullscreen;
    [self setFullscreen:fullscreen animated:NO];
}

- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated
{
    _fullscreen = fullscreen;
    
    self.playerControl.fullscreen = fullscreen;
    
    if ( fullscreen ) {
        [self.playerControl addExtraItems:self.extraItemsInControl];
    } else {
        [self.playerControl removeAllExtraItems];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.player.view.frame   = self.bounds;
    self.playerControl.frame = CGRectMake(0, self.height - 50, self.width, 50);
    
    self.spinner.center = CGPointMake(self.width / 2, self.height / 2);
}

@end

@interface VideoPlayerControlBar ()

@property (nonatomic, strong) UIView* maskView;
@property (nonatomic, strong) UIButton* playButton;
@property (nonatomic, strong) UIButton* fullscreenButton;
@property (nonatomic, strong) UISlider* progressSlider;
@property (nonatomic, strong) UILabel*  timeLabel;

@property (nonatomic, strong) NSMutableArray* extraItems;

@end
@implementation VideoPlayerControlBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        
        self.maskView = [[UIView alloc] init];
        self.maskView.backgroundColor = [UIColor blackColor];
        self.maskView.alpha = 0.85;
        [self addSubview:self.maskView];
//        self.maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.playButton = AWCreateImageButton(@"btn_play.png", self, @selector(play:));
        [self addSubview:self.playButton];
        
        self.progressSlider = [[UISlider alloc] init];
        self.progressSlider.highlighted = YES;
        [self addSubview:self.progressSlider];
        
//        [self.progressSlider addTarget:self action:@selector(updateSlider:) forControlEvents:UIControlEventValueChanged];
        
        [self.progressSlider addTarget:self action:@selector(sliderStartDrag) forControlEvents:UIControlEventTouchDown];
        [self.progressSlider addTarget:self action:@selector(sliderMoving) forControlEvents:UIControlEventTouchDragInside];
        [self.progressSlider addTarget:self action:@selector(sliderEndDrag) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        self.timeLabel = AWCreateLabel(CGRectZero,
                                       @"--/--",
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(14, NO),
                                       [UIColor whiteColor]);
        [self addSubview:self.timeLabel];
        
        self.fullscreenButton = AWCreateImageButton(@"btn_fullscreen.png", self, @selector(gotoFullscreen));
        [self addSubview:self.fullscreenButton];
        
        self.playing = NO;
        self.progress = 0.0;
    }
    return self;
}

- (void)sliderStartDrag
{
    NSLog(@"start drag...");
    if ( [self.delegate respondsToSelector:@selector(sliderStateUpdate:)] ) {
        [self.delegate sliderStateUpdate:SliderTouchStateStartDrag];
    }
}

- (void)sliderMoving
{
    NSLog(@"moving...");
    if ( [self.delegate respondsToSelector:@selector(sliderStateUpdate:)] ) {
        [self.delegate sliderStateUpdate:SliderTouchStateMoving];
    }
}

- (void)sliderEndDrag
{
    NSLog(@"end drag...");
    if ( [self.delegate respondsToSelector:@selector(sliderStateUpdate:)] ) {
        [self.delegate sliderStateUpdate:SliderTouchStateEndDrag];
    }
}

- (void)dealloc
{
    self.extraItems = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat offset = 10;
    CGFloat margin = 15;
    
    self.maskView.frame = self.bounds;
    
    self.playButton.position = CGPointMake(offset, self.height / 2 - self.playButton.height / 2);
    
    self.fullscreenButton.position = CGPointMake(self.width - offset - self.fullscreenButton.width,
                                                 self.height / 2 - self.fullscreenButton.height / 2);
    
    CGFloat left = self.fullscreenButton.left;
    for (NSInteger index = 0; index < [self.extraItems count]; index ++) {
        UIView* item = [self.extraItems objectAtIndex:index];
        item.position = CGPointMake(left - margin - item.width,
                                    self.height / 2 - item.height / 2);
        left = item.left;
    }
    
    if ( self.timeLabel.text ) {
        CGSize size = [self.timeLabel.text sizeWithAttributes:@{ NSFontAttributeName: self.timeLabel.font }];
        self.timeLabel.frame = CGRectMake(0, 0, size.width, size.height);
        self.timeLabel.position = CGPointMake(left - margin - self.timeLabel.width,
                                              self.height / 2 - self.timeLabel.height / 2);
        left = self.timeLabel.left;
    } else {
        self.timeLabel.frame = CGRectZero;
    }
    
    self.progressSlider.frame = CGRectMake(0,
                                           0,
                                           left - margin - margin - self.playButton.right + 10,
                                           40);
    self.progressSlider.center = CGPointMake(self.playButton.right + margin + self.progressSlider.width / 2,
                                             self.height / 2);
}

- (void)setPlaying:(BOOL)playing
{
    _playing = playing;
    
    if ( _playing ) {
        [self.playButton setImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    self.progressSlider.value = progress;
}

- (void)gotoFullscreen
{
    self.fullscreen = !self.fullscreen;
    if ( [self.delegate respondsToSelector:@selector(fullscreenBtnDidClick)] ) {
        [self.delegate fullscreenBtnDidClick];
    }
}

- (void)play:(UIButton *)sender
{
    self.playing = !self.playing;
    if ( [self.delegate respondsToSelector:@selector(playBtnDidClick)] ) {
        [self.delegate playBtnDidClick];
    }
}

- (void)addExtraItem:(UIView *)item
{
    if ( ![self.extraItems containsObject:item] ) {
        [self addSubview:item];
        [self.extraItems addObject:item];
    }
}

- (void)removeExtraItem:(UIView *)item
{
    if ( [self.extraItems containsObject:item] ) {
        [item removeFromSuperview];
        [self.extraItems removeObject:item];
        [self setNeedsLayout];
    }
}

- (void)addExtraItems:(NSArray<UIView *> *)items
{
    if ( [items count] > 0 ) {
        for (UIView *item in items) {
            [self addSubview:item];
        }
        [self.extraItems addObjectsFromArray:items];
        [self setNeedsLayout];
    }
}

- (void)removeAllExtraItems
{
    if ( [self.extraItems count] > 0 ) {
        
        [self.extraItems enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [self.extraItems removeAllObjects];
        
        [self setNeedsLayout];
    }
}

- (NSMutableArray *)extraItems
{
    if ( !_extraItems ) {
        _extraItems = [[NSMutableArray alloc] init];
    }
    return _extraItems;
}

@end
