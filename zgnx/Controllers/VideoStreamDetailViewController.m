//
//  VideoStreamDetailViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VideoStreamDetailViewController.h"
#import "Defines.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TabsControl.h"
#import "PlayerToolbar.h"
#import "SmallToolbar.h"
#import "VideoPlayer.h"

@interface VideoStreamDetailViewController () <TabsControlDataSource>

//@property (nonatomic, strong) MPMoviePlayerController* player;
@property (nonatomic, strong) id streamData;

@property (nonatomic, strong) TabsControl* tabsControl;

@property (nonatomic, copy) NSArray* tabsDataSource;

@property (nonatomic, strong) UIButton* backButton;

@property (nonatomic, strong) VideoPlayer* playerView;

@property (nonatomic, strong) SmallToolbar* toolbar;

@end
@implementation VideoStreamDetailViewController

- (instancetype)initWithStreamData:(id)streamData
{
    if ( self = [super init] ) {
        NSLog(@"%@", streamData);
        self.streamData = streamData;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString* videoUrl = nil;
    NSInteger type = [self.streamData[@"type"] integerValue];
    if ( type == 1 ) {
        videoUrl = [[self.streamData[@"video_file"] description] length] == 0 ?
                    [self.streamData[@"hls_url"] description] : [self.streamData[@"video_file"] description];
        
    } else {
        videoUrl = [self.streamData[@"video_file"] description];
    }
    
//    NSURL* fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test.mp4" ofType:nil]];
    self.playerView = [[VideoPlayer alloc] initWithContentURL:[NSURL URLWithString:videoUrl]];
    [self.view addSubview:self.playerView];
    
    if ( [[self.streamData[@"video_file"] description] length] > 0 ) {
        self.playerView.playerType = VideoPlayerTypeVOD;
    } else {
        self.playerView.playerType = VideoPlayerTypeLiving;
    }
    
    self.playerView.shouldAutoplay = YES;
    
    self.playerView.frame = CGRectMake(0, 0, self.view.width, self.view.width * 0.618);
    
    [self addExtraItemsInControl];
    
    __weak typeof(self)weakSelf = self;
    self.playerView.didHideControlCallback = ^(VideoPlayer* player, BOOL hidden) {
        weakSelf.backButton.hidden = hidden;
    };
    self.playerView.didClickFullscreenCallback = ^(VideoPlayer *player) {
        [weakSelf gotoFullscreen];
    };
    
    // 返回按钮
    self.backButton = AWCreateImageButton(@"live_v_btn_back.png", self, @selector(back));
    [self.view addSubview:self.backButton];
    self.backButton.position = CGPointMake(10, 10);
    
    // 竖屏工具条
    [self initToolbar];
    
    // 分栏视图控件
    [self initTabPage];
}

- (void)initTabPage
{
    //
    //    self.tabsDataSource = @[@"弹幕",@"节目介绍",@"回看",@"打赏"];
    //    self.tabsControl = [[TabsControl alloc] initWithFrame:CGRectMake(0, self.toolbar.bottom,
    //                                                                     self.view.width,
    //                                                                     self.view.height - self.toolbar.bottom)
    //                                             tabsPosition:TabsPositionTop];
    //    [self.view addSubview:self.tabsControl];
    //    self.tabsControl.dataSource = self;
}

- (void)initToolbar
{
    self.toolbar = [[SmallToolbar alloc] initWithVideoInfo:self.streamData];
    [self.view addSubview:self.toolbar];
    self.toolbar.position = CGPointMake(0, self.playerView.bottom);
    self.toolbar.backgroundColor = AWColorFromRGB(186,186,186);
    
    __weak typeof(self)weakSelf = self;
    self.toolbar.toolbarButtonDidTapBlock = ^(UIButton* sender) {
        switch (sender.tag) {
            case ToolbarButtonTagBili:
            {
                [weakSelf openOrCloseBili:sender];
            }
                break;
            case ToolbarButtonTagLike:
            {
                [weakSelf doLike:sender];
            }
                break;
            case ToolbarButtonTagShare:
            {
                [weakSelf doShare];
            }
                break;
                
            default:
                break;
        }
    };
}

- (void)addExtraItemsInControl
{
    NSMutableArray* items = [NSMutableArray array];
    UIButton* likeBtn = AWCreateImageButton(@"btn_like.png", self, @selector(doLike:));
    [likeBtn setImage:[UIImage imageNamed:@"btn_liked.png"] forState:UIControlStateSelected];
    likeBtn.selected = [self.streamData[@"liked"] boolValue];
    [items addObject:likeBtn];
    
    UIButton* shareBtn = AWCreateImageButton(@"btn_share.png", self, @selector(doShare));
    [items addObject:shareBtn];
    
    UIButton* danmu = AWCreateImageButton(@"danmu.png", self, @selector(openOrCloseBili:));
    [danmu setImage:[UIImage imageNamed:@"danmu_h.png"] forState:UIControlStateSelected];
    danmu.selected = YES;
    [items addObject:danmu];
    
    self.playerView.extraItemsInControl = items;
}

- (void)doLike:(UIButton *)sender
{
    
}

- (void)doShare
{
    
}

- (void)openOrCloseBili:(UIButton *)sender
{
    
}

- (void)back
{
    if ( self.playerView.fullscreen ) {
        [self gotoFullscreen];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSUInteger)numberOfTabs:(TabsControl *)tabsControl
{
    return [self.tabsDataSource count];
}

- (NSString *)tabs:(TabsControl *)tabsControl titleForItemAtIndex:(NSInteger)index
{
    return self.tabsDataSource[index];
}

- (UIView *)tabs:(TabsControl *)tabsControl viewForItemAtIndex:(NSInteger)index
{
    UIView* view = [tabsControl dequeueReusableViewForIndex:index];
    if ( !view ) {
        view = [[UIView alloc] init];
        
        switch (index) {
            case 0:
            {
                UITextField* biliTextField = [[UITextField alloc] init];
                biliTextField.frame = CGRectMake(0, tabsControl.height - 44 - 44, AWFullScreenWidth(), 44);
                [view addSubview:biliTextField];
                biliTextField.placeholder = @"输入弹幕";
            }
                break;
            case 1:
            {
                
            }
                break;
            case 2:
            {
                
            }
                break;
            case 3:
            {
                
            }
                break;
                
            default:
                break;
        }
    }
    
    return view;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

// ios7
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willRotateToInterfaceOrientation: %d, %f", toInterfaceOrientation, self.view.width);
    CGRect frame = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ?
    CGRectMake(0, 0, self.view.height, self.view.width) :
    CGRectMake(0, 0, self.view.width, self.view.width * 0.618);
    
    self.playerView.fullscreen = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    
    [UIView animateWithDuration:duration animations:^{
        self.playerView.frame = frame;
        self.backButton.position = CGPointMake(10, 10);
    }];
    
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ) {
        self.tabsControl.hidden = YES;
    } else {
        self.tabsControl.hidden = NO;
    }
    
    self.toolbar.hidden = self.tabsControl.hidden;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"didRotateFromInterfaceOrientation: %d", fromInterfaceOrientation);
}

// ios8以上
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    CGRect frame = size.width > size.height ? CGRectMake(0, 0, size.width, size.height)
    : CGRectMake(0, 0, size.width, size.width * 0.618);
    
    self.tabsControl.hidden = size.width > size.height;
    self.toolbar.hidden = self.tabsControl.hidden;
    
    self.playerView.fullscreen = self.toolbar.hidden;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //
        self.playerView.frame = frame;
        self.backButton.position = CGPointMake(10, 10);
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)gotoFullscreen
{
    if ( UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    } else {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
    }
}

@end
