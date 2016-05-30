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

@interface VideoStreamDetailViewController () <TabsControlDataSource>

@property (nonatomic, strong) MPMoviePlayerController* player;
@property (nonatomic, strong) id streamData;

@property (nonatomic, strong) TabsControl* tabsControl;

@property (nonatomic, copy) NSArray* tabsDataSource;

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
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:
                   [NSURL URLWithString:self.streamData[@"video_file"]]];
    self.player.view.frame = CGRectMake(0, 0, self.view.width,
                                        self.view.width * 0.618);
    [self.view addSubview:self.player.view];
    
    self.player.controlStyle = MPMovieControlStyleNone;
    self.player.scalingMode = MPMovieScalingModeAspectFit;
    self.player.fullscreen = NO;

    [self addPlayerToolbar];
    
    self.tabsDataSource = @[@"弹幕",@"节目介绍",@"回看",@"打赏"];
    
    self.tabsControl = [[TabsControl alloc] initWithFrame:CGRectMake(0, self.player.view.bottom,
                                                                     self.view.width,
                                                                     self.view.height - self.player.view.bottom)
                                             tabsPosition:TabsPositionTop];
    [self.view addSubview:self.tabsControl];
    self.tabsControl.dataSource = self;
}

- (void)addPlayerToolbar
{
//    [self.player.view addSubview:]
    
//    UIButton* playBtn = AWCreateImageButton(@"btn_play.png", self, @selector(play:));
//    [self.player.view addSubview:playBtn];
//    playBtn.center = CGPointMake(, <#CGFloat y#>)
    
    PlayerToolbar* toolbar1 = [[PlayerToolbar alloc] initWithLeftButtonImage:@"live_v_btn_back.png"
                                                            rightButtonImage:@"live_v_btn_collect.png"];
    [self.player.view addSubview:toolbar1];
    toolbar1.frame = CGRectMake(0, 0, self.player.view.width, 40);
    toolbar1.tag = 10011;
    
    __weak typeof(self) weakSelf = self;
    toolbar1.leftButtonClickBlock = ^(PlayerToolbar* toolbar, UIButton* sender) {
        [weakSelf back];
    };
    
    toolbar1.rightButtonClickBlock = ^(PlayerToolbar* toolbar, UIButton* sender) {
        [weakSelf doFavorite];
    };
    
    PlayerToolbar* toolbar2 = [[PlayerToolbar alloc] initWithLeftButtonImage:@"live_v_btn_share.png"
                                                            rightButtonImage:@"live_v_btn_qp.png"];
    [self.player.view addSubview:toolbar2];
    toolbar2.frame = CGRectMake(0, self.player.view.height - 40, self.player.view.width, 40);
    toolbar2.tag = 10012;
    
    toolbar2.leftButtonClickBlock = ^(PlayerToolbar* toolbar, UIButton* sender) {
        [weakSelf gotoShare];
    };
    
    toolbar2.rightButtonClickBlock = ^(PlayerToolbar* toolbar, UIButton* sender) {
        [weakSelf gotoFullscreen];
    };
}

- (void)doFavorite
{
    
}

- (void)gotoShare
{
    
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [UIView animateWithDuration:duration animations:^{
        self.player.view.frame = frame;
        [[self.player.view viewWithTag:10011] setFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 40)];
        [[self.player.view viewWithTag:10012] setFrame:CGRectMake(0, CGRectGetHeight(frame) - 40, CGRectGetWidth(frame), 40)];
    }];
    
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ) {
        self.tabsControl.hidden = YES;
    } else {
        self.tabsControl.hidden = NO;
    }
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
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //
        self.player.view.frame = frame;
        
        [[self.player.view viewWithTag:10011] setFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 40)];
        [[self.player.view viewWithTag:10012] setFrame:CGRectMake(0, CGRectGetHeight(frame) - 40, CGRectGetWidth(frame), 40)];
        
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
