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
#import "SmallToolbar.h"
#import "VideoPlayer.h"
#import "ButtonGroup.h"
#import "PanelView.h"
#import "VideoIntroView.h"
#import "BiliView.h"
#import "ViewHistoryService.h"
#import "ViewHistory.h"
#import "LoadDataService.h"
#import "Stream.h"

@interface VideoStreamDetailViewController () <PanelViewDataSource>

//@property (nonatomic, strong) id streamData;

@property (nonatomic, copy) NSArray* tabsDataSource;

@property (nonatomic, strong) UIButton* backButton;

@property (nonatomic, strong) VideoPlayer* playerView;

@property (nonatomic, strong) SmallToolbar* toolbar;

@property (nonatomic, strong) ButtonGroup* buttonGroup;
@property (nonatomic, strong) PanelView* panelView;

@property (nonatomic, strong) VideoIntroView* introView;

@property (nonatomic, assign) NSUInteger videoFromType;

@property (nonatomic, strong) ViewHistoryService *vhService;

@property (nonatomic, strong) LoadDataService *likeService;

@property (nonatomic, strong) Stream *stream;

@property (nonatomic, strong) BiliView *biliView;

@end

@implementation VideoStreamDetailViewController

- (instancetype)initWithStreamData:(id)streamData fromType:(VideoFromType)fromType
{
    if ( self = [super init] ) {
        NSLog(@"%@", streamData);
//        self.streamData = streamData;
        
//        NSInteger type = streamData[@"from_type"] ? [streamData[@"from_type"] integerValue] : 0;
//        self.videoFromType = type;
    }
    return self;
}

- (instancetype)initWithStream:(Stream *)aStream
{
    if ( self = [super init] ) {
        self.stream = aStream;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString* videoUrl = nil;
//    NSInteger type = [self.streamData[@"type"] integerValue];
    if ( [self.stream.type integerValue] == 1 ) {
        videoUrl = [self.stream.video_file length] == 0 ?
                    self.stream.hls_url : self.stream.video_file;
        
    } else {
        videoUrl = self.stream.video_file;
    }
    
//    NSURL* fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test.mp4" ofType:nil]];
    self.playerView = [[VideoPlayer alloc] initWithContentURL:[NSURL URLWithString:videoUrl]];
    [self.view addSubview:self.playerView];
    
    if ( [self.stream.video_file length] > 0 ) {
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
    self.backButton = AWCreateImageButton(@"live_v_btn_back.png",
                                          self,
                                          @selector(back));
    [self.view addSubview:self.backButton];
    self.backButton.position = CGPointMake(10, 10);
    
    // 竖屏工具条
    [self initToolbar];
    
    // 分栏视图控件
    [self initTabPage];
}

- (void)dealloc
{
    [self.playerView finishPlaying];
    self.playerView = nil;
}

- (void)initTabPage
{
    NSArray* normalImages = @[@"column_btn_tm_n.png",
                              @"column_btn_jmjs_n.png",
                              @"column_btn_syg.png"];
    
    NSArray* selectedImages = @[@"column_btn_tm_s.png",
                              @"column_btn_jmjs_s.png",
                              @"column_btn_syg.png"];
    
    self.buttonGroup = [[ButtonGroup alloc] initWithFrame:
                        CGRectMake(0, self.toolbar.bottom, self.view.width, 44)
                                       buttonNormalImages:normalImages
                                     buttonSelectedImages:selectedImages];
    [self.view addSubview:self.buttonGroup];
    
    __weak typeof(self)weakSelf = self;
    self.buttonGroup.didSelectItemBlock = ^(ButtonGroup *group) {
        weakSelf.panelView.selectedIndex = group.selectedIndex;
    };
    
    self.panelView = [[PanelView alloc] init];
    [self.view addSubview:self.panelView];
    self.panelView.frame = CGRectMake(0,
                                      self.buttonGroup.bottom,
                                      self.view.width,
                                      self.view.height - self.buttonGroup.bottom);
    self.panelView.dataSource = self;
    self.panelView.selectedIndex = 0;
}

- (void)initToolbar
{
    self.toolbar = [[SmallToolbar alloc] initWithStream:self.stream];
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

- (NSInteger)numberOfPages:(PanelView *)panelView
{
    return 3;
}

- (UIView *)panelView:(PanelView *)panelView viewAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            return self.biliView;
        case 1:
            return self.introView;
        case 2:
            return [[UIView alloc] init];
            
        default:
            return [[UIView alloc] init];
    }
}

- (VideoIntroView *)introView
{
    if (!_introView) {
        _introView = [[VideoIntroView alloc] init];
        [_introView setBody:self.stream.body];
    }
    return _introView;
}

- (BiliView *)biliView
{
    if ( !_biliView ) {
        _biliView = [[BiliView alloc] init];
        _biliView.streamId = @"2";
    }
    
    return _biliView;
}

- (void)addExtraItemsInControl
{
    NSMutableArray* items = [NSMutableArray array];
    UIButton* likeBtn = AWCreateImageButton(@"btn_like.png", self, @selector(doLike:));
    [likeBtn setImage:[UIImage imageNamed:@"btn_liked.png"] forState:UIControlStateSelected];
    likeBtn.selected = [self.stream.liked boolValue];
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
    User* user = [[UserService sharedInstance] currentUser];
    if ( !user ) {
        UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openLoginVC];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    NSString* uri = nil;
    if ( sender.selected == NO ) {
        // 收藏
        uri = API_USER_LIKE;
    } else {
        // 取消收藏
        uri = API_USER_CANCEL_LIKE;
    }
    
    __weak typeof(self) me = self;
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    [self.likeService POST:uri params:@{ @"token": user.authToken ?: @"",
                                         @"likeable_id": self.stream.id_,
                                         @"type": self.stream.type ?: @"",
                                         } completion:^(id result, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:me.contentView animated:YES];
        if ( !error ) {
            if ( [uri isEqualToString:API_USER_LIKE] ) {
                me.stream.liked = @(1);
                sender.selected = YES;
            } else {
                me.stream.liked = @(0);
                sender.selected = NO;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNeedReloadDataNotification" object:me.stream];
        } else {
            if ( [uri isEqualToString:API_USER_LIKE] ) {
                me.stream.liked = @(0);
                sender.selected = NO;
            } else {
                me.stream.liked = @(1);
                sender.selected = YES;
            }
        }
    }];
}

- (void)doShare
{
    
}

- (void)openOrCloseBili:(UIButton *)sender
{
    
}

- (LoadDataService *)likeService
{
    if ( !_likeService ) {
        _likeService = [[LoadDataService alloc] init];
    }
    return _likeService;
}

- (void)back
{
    if ( self.playerView.fullscreen ) {
        [self gotoFullscreen];
    } else {
        // 记录观看历史
        if ( self.stream.fromType == StreamFromTypeDefault &&
            [self.stream.type integerValue] == 2) {
            if ( !self.vhService ) {
                self.vhService = [[ViewHistoryService alloc] init];
            }
            
            self.stream.currentPlaybackTime =
            [@(self.playerView.currentPlaybackTime) description];
            
            [self.vhService saveRecord:self.stream needSyncServer:YES];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
//    NSLog(@"willRotateToInterfaceOrientation: %d, %f", toInterfaceOrientation, self.view.width);
    CGRect frame = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ?
    CGRectMake(0, 0, self.view.height, self.view.width) :
    CGRectMake(0, 0, self.view.width, self.view.width * 0.618);
    
    self.playerView.fullscreen = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    
    [UIView animateWithDuration:duration animations:^{
        self.playerView.frame = frame;
        self.backButton.position = CGPointMake(10, 10);
    }];
    
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ) {
//        self.tabsControl.hidden = YES;
        self.buttonGroup.hidden = self.panelView.hidden = YES;
    } else {
//        self.tabsControl.hidden = NO;
        self.buttonGroup.hidden = self.panelView.hidden = NO;
    }
    
    self.toolbar.hidden = self.buttonGroup.hidden;
}

// ios8以上
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    CGRect frame = size.width > size.height ? CGRectMake(0, 0, size.width, size.height)
    : CGRectMake(0, 0, size.width, size.width * 0.618);
    
    self.toolbar.hidden = size.width > size.height;

    self.playerView.fullscreen = self.toolbar.hidden;
    
    self.buttonGroup.hidden = self.panelView.hidden = self.toolbar.hidden;
    
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
