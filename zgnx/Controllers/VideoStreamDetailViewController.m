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
#import "VideoPlayerView.h"
#import "GrantView.h"
#import "Bilibili.h"
#import "DMSManager.h"
#import "BiliInputControl.h"

@interface VideoStreamDetailViewController () <PanelViewDataSource>

//@property (nonatomic, strong) id streamData;

@property (nonatomic, copy) NSArray* tabsDataSource;

@property (nonatomic, strong) UIButton* backButton;

//@property (nonatomic, strong) VideoPlayer* playerView;
@property (nonatomic, strong) VideoPlayerView *playerView;

@property (nonatomic, strong) SmallToolbar* toolbar;

@property (nonatomic, strong) ButtonGroup* buttonGroup;
@property (nonatomic, strong) PanelView* panelView;

@property (nonatomic, strong) VideoIntroView* introView;

@property (nonatomic, assign) NSUInteger videoFromType;

@property (nonatomic, strong) ViewHistoryService *vhService;

@property (nonatomic, strong) LoadDataService *likeService;
@property (nonatomic, strong) LoadDataService *favoriteService;
@property (nonatomic, strong) LoadDataService *payService;
@property (nonatomic, strong) LoadDataService *socialStateService;

@property (nonatomic, strong) Stream *stream;

@property (nonatomic, strong) BiliView *biliView;
@property (nonatomic, strong) GrantView *grantView;

@property (nonatomic, strong) NSArray *extraButtons;

@property (nonatomic, strong) UIButton *biliButton;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *favoriteButton;

@property (nonatomic, assign) BOOL allowRotation;

@property (nonatomic, assign) BOOL needLoadSocialState;

@property (nonatomic, strong) BiliInputControl *inputControl;

@property (nonatomic, strong) DMSManager *dmsManager;

@property (nonatomic, assign) BOOL biliOpening;

@end

@implementation VideoStreamDetailViewController

- (instancetype)initWithStream:(Stream *)aStream
{
    if ( self = [super init] ) {
        self.stream = aStream;
        self.allowRotation = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.biliOpening = YES;
    
    self.dmsManager = [[DMSManager alloc] initWithClientId:[[NSProcessInfo processInfo] globallyUniqueString]];
    
    NSString* videoUrl = nil;
    if ( [self.stream.type integerValue] == 1 ) {
        videoUrl = [self.stream.video_file length] == 0 ?
                    self.stream.rtmp_url : self.stream.video_file;
        
    } else {
        videoUrl = self.stream.video_file;
    }
    
//    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test1.mp4" ofType:nil]];
    NSURL* url = [NSURL URLWithString:videoUrl];
    self.playerView = [[VideoPlayerView alloc] initWithContentURL:url params:nil];
    [self.view addSubview:self.playerView];
    
    if ( [self.stream.type integerValue] == 1 ) {
        if ( [self.stream.video_file length] == 0 ) {
            self.playerView.mediaType = VideoPlayerMediaTypeLive;
        } else {
            self.playerView.mediaType = VideoPlayerMediaTypeVOD;
        }
    } else {
        self.playerView.mediaType = VideoPlayerMediaTypeVOD;
    }
    
    self.playerView.currentPlaybackTime = [self.stream.currentPlaybackTime doubleValue];
    
    __weak typeof(self) me = self;
    self.playerView.didShutdownPlayerBlock = ^(VideoPlayerView *view, NSTimeInterval progress) {
        [me recordViewHistory:progress];
        [me dismissViewControllerAnimated:YES completion:nil];
    };
    
    self.playerView.didTogglePlayerModeBlock = ^(VideoPlayerView *view, VideoPlayerMode mode) {
        [me gotoFullscreen];
    };
    
    self.playerView.frame = CGRectMake(0, 0, self.view.width, self.view.width * 0.618);
    
//    [self addExtraItemsInControl];
    
    // 竖屏工具条
    [self initToolbar];
    
    // 分栏视图控件
    [self initTabPage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(biliHistoryDidLoad:)
                                                 name:@"kBiliHistoryDidLoadNotification"
                                               object:nil];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self biliHistoryDidLoad:nil];
//    });
    [self addDMSFunc];
}

- (void)addDMSFunc
{
    __weak typeof(self) me = self;

    [self.dmsManager addMessageHandler:^(MQTTMessage *message) {
        NSLog(@"msg: %@", message);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 添加到消息列表
            [me.biliView addJSONMessage:message.payloadString];
            // 显示弹幕
            NSData *jsonData = [message.payloadString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonMsg = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            [me.playerView showBilibili:jsonMsg[@"msg"]];
        });
    }];
    
    [self.dmsManager connect:^(BOOL succeed, NSError *error) {
        //        NSLog(@"error:%@", error);
    }];
    
    [self.dmsManager subscribe:self.stream.stream_id completion:^(BOOL succeed, NSError *error) {
        if ( succeed ) {
            NSLog(@"订阅主题成功");
        }
    }];
}

- (void)initTabPage
{
    NSArray* normalImages = nil;//@[@"column_btn_tm_n.png",
                            //@"column_btn_jmjs_n.png",
                            //@"column_btn_syg.png"];
    
    NSArray* selectedImages = nil;//@[@"column_btn_tm_s.png",
                              //@"column_btn_jmjs_s.png",
                              //@"column_btn_syg.png"];
    
    self.buttonGroup = [[ButtonGroup alloc] initWithFrame:
                        CGRectMake(0, self.toolbar.bottom, self.view.width, 44)
                                       buttonNormalImages:normalImages
                                     buttonSelectedImages:selectedImages];
    [self.view addSubview:self.buttonGroup];
    
    UIButton *grantButton = AWCreateImageButton(nil, self, @selector(gotoGrant));
    grantButton.frame = CGRectMake(0, 0, self.view.width / 3, 44);
    [self.buttonGroup addSubview:grantButton];
    grantButton.left = self.view.width - grantButton.width;
    grantButton.backgroundColor = AWColorFromRGB(239,16,17);
    
    [grantButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [grantButton setTitle:@"赏一个" forState:UIControlStateNormal];
    
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

- (BOOL)userLogined
{
    User* user = [[UserService sharedInstance] currentUser];
    if ( !user ) {
        self.needLoadSocialState = YES;
        UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openLoginVC];
        [self presentViewController:vc animated:YES completion:nil];
        return NO;
    }
    
    self.needLoadSocialState = NO;
    return YES;
}

- (void)gotoGrant
{
    if ( [self userLogined] == NO ) {
        return;
    }
    
    self.allowRotation = NO;
    GrantView *gView = [[GrantView alloc] init];
    
    User *user = [[UserService sharedInstance] currentUser];
    
    __weak typeof(gView) weakGV = gView;
    __weak typeof(self) me = self;
    gView.didCancelBlock = ^{
        self.allowRotation = YES;
    };
    gView.didPayBlock = ^(CGFloat money, NSString *password){
        if ( money < 0.01 ) {
            [[[UIAlertView alloc] initWithTitle:@"至少需要一角钱"
                                       message:@""
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles: nil] show];
            return;
        }
        [MBProgressHUD showHUDAddedTo:me.view animated:YES];
        
        NSString *token = user.authToken ?: @"";
        NSString *pass = [NSString stringWithFormat:@"f765a3873ffafdeeeedad552f6b659881047e1553fd18f34905a7260a547306b459f43d79c7c5529a1de9b4a2719d4248abcc26eb9af446e25e7dd62b53a9394%@", password];
        NSString *passString = [[pass dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        [self.payService POST:API_USER_GRANT
                       params:@{ @"token": token,
                                 @"money": @(money),
                                 @"pay_password": passString,
                                 @"to": self.stream.user.id_ ?: @"",
                                 }
                   completion:^(id result, NSError *error) {
                       [MBProgressHUD hideHUDForView:me.view animated:YES];
                       if ( error ) {
                           [[[UIAlertView alloc] initWithTitle:error.domain
                                                       message:@""
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil] show];
                       } else {
                           [weakGV dismiss];
                       }
                       
        }];
    };
    [gView showInView:self.view];
}

- (void)initToolbar
{
    self.toolbar = [[SmallToolbar alloc] initWithStream:self.stream];
    [self.view addSubview:self.toolbar];
    self.toolbar.position = CGPointMake(0, self.playerView.bottom);
    
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
            case ToolbarButtonTagFavorite:
            {
                [weakSelf doFavorite:sender];
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
            return self.grantView;
            
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
    
    self.inputControl.hidden = YES;
    [self.inputControl hideKeyboard];
    
    return _introView;
}

- (BiliView *)biliView
{
    if ( !_biliView ) {
        _biliView = [[BiliView alloc] init];
        _biliView.streamId = self.stream.stream_id;
//        __weak typeof(self) me = self;
//        _biliView.didSendBiliBlock = ^(BiliView *view, Bilibili *bili) {
//            // 如果开启了弹幕功能，就发送弹幕
////            [me.playerView showBilibili:bili.content];
//            
//            // 广播给其他用户
//            [[DMSManager sharedInstance] sendMessage:[bili jsonMessage]
//                                             toTopic:me.stream.stream_id
//                                          completion:^(int msgId, NSError *error) {
//                if ( !error ) {
//                    NSLog(@"发送成功！");
//                } else {
//                    NSLog(@"发送失败：%@", error);
//                }
//            }];
//        };
    }
    
    self.inputControl.hidden = NO;
    
    return _biliView;
}

- (GrantView *)grantView
{
    if ( !_grantView ) {
        _grantView = [[GrantView alloc] init];
    }
    
    self.inputControl.hidden = YES;
    [self.inputControl hideKeyboard];
    
    return _grantView;
}

- (void)doLike:(UIButton *)sender
{
    if ( [self userLogined] == NO ) {
        return;
    }
    
    NSString* uri = nil;
    if ( sender.selected == NO ) {
        // 点赞
        uri = API_USER_LIKE;
    } else {
        // 取消点赞
        uri = API_USER_CANCEL_LIKE;
    }
    
    User *user = [[UserService sharedInstance] currentUser];
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
                me.toolbar.likeButton.selected = YES;
            } else {
                me.stream.liked = @(0);
                sender.selected = NO;
                me.toolbar.likeButton.selected = NO;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNeedReloadDataNotification" object:me.stream];
        } else {
            if ( [uri isEqualToString:API_USER_LIKE] ) {
                me.stream.liked = @(0);
                sender.selected = NO;
                me.toolbar.likeButton.selected = NO;
            } else {
                me.stream.liked = @(1);
                sender.selected = YES;
                me.toolbar.likeButton.selected = YES;
            }
        }
    }];
}

- (void)doFavorite:(UIButton *)sender
{
    if ( [self userLogined] == NO ) {
        return;
    }
    
    User* user = [[UserService sharedInstance] currentUser];
    
    NSString* uri = nil;
    if ( sender.selected == NO ) {
        // 收藏
        uri = API_USER_FAVORITE;
    } else {
        // 取消收藏
        uri = API_USER_CANCEL_FAVORITE;
    }
    
    __weak typeof(self) me = self;
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    [self.likeService POST:uri params:@{ @"token": user.authToken ?: @"",
                                         @"favorite_id": self.stream.id_,
                                         @"type": self.stream.type ?: @"",
     } completion:^(id result, NSError *error) {
         [MBProgressHUD hideAllHUDsForView:me.contentView animated:YES];
         if ( !error ) {
             if ( [uri isEqualToString:API_USER_FAVORITE] ) { // 收藏成功
                 me.stream.favorited = @(1);
                 sender.selected = YES;
                 me.toolbar.favoriteButton.selected = YES;
             } else { // 取消收藏成功
                 me.stream.favorited = @(0);
                 sender.selected = NO;
                 me.toolbar.favoriteButton.selected = NO;
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:@"kNeedReloadDataNotification" object:me.stream];
         } else {
             if ( [uri isEqualToString:API_USER_FAVORITE] ) { // 收藏失败
                 me.stream.favorited = @(0);
                 sender.selected = NO;
                 me.toolbar.favoriteButton.selected = NO;
             } else { // 取消收藏失败
                 me.stream.favorited = @(1);
                 sender.selected = YES;
                 me.toolbar.favoriteButton.selected = YES;
             }
         }
     }];
}

- (void)openOrCloseBili:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    self.biliOpening = sender.selected;
    
    self.toolbar.bilibiliButton.selected = self.biliOpening;
    
    [self.playerView openBilibili:sender.selected];
}

- (void)biliHistoryDidLoad:(NSNotification *)noti
{
    NSArray *bilis = noti.object;
    NSMutableArray *tempArr = [NSMutableArray array];
    [bilis enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *bili = nil;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            bili = obj[@"content"];
        } else if ( [obj isKindOfClass:[Bilibili class]] ) {
            bili = [obj content];
        }
        [tempArr insertObject:bili atIndex:0];
    }];
    
    // 加入测试数据
#if DEBUG
    if ( [tempArr count] == 0 ) {
        for (int i = 0; i<30; i++) {
            if ( arc4random_uniform(10) % 2 == 0 ) {
                [tempArr addObject:@"Hi, 不错哦～"];
            } else {
                [tempArr addObject:[NSString stringWithFormat:@"this is cool bili %d", i]];
            }
            
        }
    }
    NSLog(@"bili msg: %@", tempArr);
#endif
    
    self.playerView.bilibiliHistories = tempArr;
}

- (LoadDataService *)likeService
{
    if ( !_likeService ) {
        _likeService = [[LoadDataService alloc] init];
    }
    return _likeService;
}

- (LoadDataService *)favoriteService
{
    if ( !_favoriteService ) {
        _favoriteService = [[LoadDataService alloc] init];
    }
    return _favoriteService;
}

- (LoadDataService *)payService
{
    if ( !_payService ) {
        _payService = [[LoadDataService  alloc] init];
    }
    return _payService;
}

- (LoadDataService *)socialStateService
{
    if ( !_socialStateService ) {
        _socialStateService = [[LoadDataService  alloc] init];
    }
    return _socialStateService;
}

- (void)recordViewHistory:(NSTimeInterval)progress
{
    // 记录观看历史
    if ( [self.stream.type integerValue] == 2 || ([self.stream.video_file length] != 0) ) {
        // 点播或者直播里面的点播视频都可以记录观看历史
        self.stream.currentPlaybackTime = [@(progress) description];
        if ( !self.vhService ) {
            self.vhService = [[ViewHistoryService alloc] init];
        }

        [self.vhService saveRecord:self.stream needSyncServer:YES];
    }
}

- (NSArray *)extraButtons
{
    if ( !_extraButtons ) {
        _extraButtons = [[NSArray alloc] initWithObjects:self.biliButton,self.likeButton, self.favoriteButton, nil];
    }
    
    self.biliButton.selected = !self.biliOpening;
    self.likeButton.selected = [self.stream.liked boolValue];
    self.favoriteButton.selected = [self.stream.favorited boolValue];
    
    return _extraButtons;
}

- (UIButton *)biliButton
{
    if ( !_biliButton ) {
        _biliButton = AWCreateImageButton(@"btn_bili_open.png",
                                          self, @selector(openOrCloseBili:));
        [_biliButton setImage:[UIImage imageNamed:@"btn_bili_close.png"]
                     forState:UIControlStateSelected];
        _biliButton.selected = !self.biliOpening;
    }
    
    return _biliButton;
}

- (BiliInputControl *)inputControl
{
    if ( !_inputControl) {
        _inputControl = [[BiliInputControl alloc] init];
        [self.view addSubview:_inputControl];
        _inputControl.top = self.view.height - _inputControl.height;
        _inputControl.left = 0;
        
        __weak typeof(self) me = self;
        _inputControl.didSendMessageBlock = ^(NSString *msg) {
            Bilibili *bili = [[Bilibili alloc] init];
            
            User *user = [[UserService sharedInstance] currentUser];
            if ( !user ) {
                bili.avatarUrl = @"";
                bili.nickname  = @"游客";
            } else {
                bili.avatarUrl = user.avatarUrl;
                bili.nickname = user.nickname ?: user.hackMobile;
            }
            
            bili.streamId = [me.stream.stream_id description];
            bili.content = msg;
            
            // 发送到我们自己的服务器
            [me.biliView sendBiliToServer:bili];
            
            // 广播给其他用户
            [me.dmsManager sendMessage:[bili jsonMessage]
                                             toTopic:me.stream.stream_id
                                          completion:^(int msgId, NSError *error) {
                if ( !error ) {
                    NSLog(@"发送成功！");
                } else {
                    NSLog(@"发送失败：%@", error);
                }
            }];
        };
    }
    [self.view bringSubviewToFront:_inputControl];
    return _inputControl;
}

- (UIButton *)likeButton
{
    if ( !_likeButton ) {
        _likeButton = AWCreateImageButton(@"tags_zan_n.png",
                                          self, @selector(doLike:));
        [_likeButton setImage:[UIImage imageNamed:@"tags_zan_y.png"]
                     forState:UIControlStateSelected];
    }
    
    _likeButton.selected = [self.stream.liked boolValue];
    
    return _likeButton;
}

- (UIButton *)favoriteButton
{
    if ( !_favoriteButton ) {
        _favoriteButton = AWCreateImageButton(@"btn_favorite.png",
                                          self, @selector(doFavorite:));
        [_favoriteButton setImage:[UIImage imageNamed:@"btn_favorited.png"]
                     forState:UIControlStateSelected];
    }
    
    _favoriteButton.selected = [self.stream.favorited boolValue];
    
    return _favoriteButton;
}

- (BOOL)shouldAutorotate
{
    return self.allowRotation;
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
    
//    self.playerView.fullscreen = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    self.playerView.playerMode = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? VideoPlayerModeFullscreen : VideoPlayerModeDefault;
    
    if ( self.playerView.playerMode == VideoPlayerModeFullscreen ) {
        [self.playerView addExtraItemsAtBottomControl:self.extraButtons];
    } else {
        [self.playerView addExtraItemsAtBottomControl:nil];
    }
    
    [self.playerView openBilibili:NO];
    
    [UIView animateWithDuration:duration animations:^{
        self.playerView.frame = frame;
        self.backButton.position = CGPointMake(10, 10);
    } completion:^(BOOL finished) {
        [self.playerView openBilibili:YES];
    }];
    
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ) {
//        self.tabsControl.hidden = YES;
        self.buttonGroup.hidden = self.panelView.hidden = YES;
        self.inputControl.hidden = YES;
        [self.inputControl hideKeyboard];
    } else {
//        self.tabsControl.hidden = NO;
        self.buttonGroup.hidden = self.panelView.hidden = NO;
//        self.inputControl.hidden = NO
        if ( self.panelView.selectedIndex == 0 ) {
            self.inputControl.hidden = NO;
        }
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

    self.playerView.playerMode = self.toolbar.hidden ? VideoPlayerModeFullscreen : VideoPlayerModeDefault;
    
    if ( self.playerView.playerMode == VideoPlayerModeFullscreen ) {
        [self.playerView addExtraItemsAtBottomControl:self.extraButtons];
    } else {
        [self.playerView addExtraItemsAtBottomControl:nil];
    }
    
    self.buttonGroup.hidden = self.panelView.hidden = self.toolbar.hidden;
    
    if ( self.panelView.hidden ) {
        self.inputControl.hidden = YES;
        [self.inputControl hideKeyboard];
    } else {
        if ( self.panelView.selectedIndex == 0 ) {
            self.inputControl.hidden = NO;
        }
    }
    
    [self.playerView openBilibili:NO];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //
        self.playerView.frame = frame;
        self.backButton.position = CGPointMake(10, 10);
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //
        [self.playerView openBilibili:YES];
    }];
}

- (void)loadSocialState
{
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
    [self.socialStateService GET:@"/user/social_state" params:@{
                                                                @"token": token,
                                                                @"type": self.stream.type ?: @(2),
                                                                @"vid": self.stream.id_,
                                                                } completion:^(id result, NSError *error) {
                                                                    [MBProgressHUD hideHUDForView:me.contentView animated:YES];
                                                                    if ( !error ) {
                                                                        BOOL liked = [result[@"liked"] boolValue];
                                                                        BOOL favorited = [result[@"liked"] boolValue];
                                                                        
                                                                        me.stream.liked = @(liked);
                                                                        me.stream.favorited = @(favorited);
                                                                        
                                                                        me.likeButton.selected = liked;
                                                                        me.favoriteButton.selected = favorited;
                                                                    }
                                                                }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if ( self.needLoadSocialState ) {
        User *user = [[UserService sharedInstance] currentUser];
        if ( user ) {
            [self loadSocialState];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.allowRotation = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.dmsManager unsubscribe:self.stream.stream_id completion:^(BOOL succeed, NSError *error) {
        
    }];
    [self.dmsManager disconnect:^(BOOL succeed, NSError *error) {
        
    }];
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
