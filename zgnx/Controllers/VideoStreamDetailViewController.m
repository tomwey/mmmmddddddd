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

@interface VideoStreamDetailViewController ()

@property (nonatomic, strong) MPMoviePlayerController* player;
@property (nonatomic, strong) id streamData;

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
    
    [self.player prepareToPlay];
    self.player.shouldAutoplay = NO;
    
    self.player.scalingMode = MPMovieScalingModeAspectFit;
    
    self.player.fullscreen = NO;
    
//    self.player.controlStyle = MPMovieControlStyleFullscreen;
    
    UIButton* backBtn = AWCreateTextButton(CGRectMake(10, 30, 44, 44),
                                           @"返回",
                                           [UIColor redColor],
                                           self,
                                           @selector(back));
    [self.view addSubview:backBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterFullscreen)
                                                 name:MPMoviePlayerWillEnterFullscreenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willExitFullscreen)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    
}

- (void)willEnterFullscreen
{
    NSLog(@"willEnterFullscreen");
    self.player.fullscreen = NO;
    [self back];
}
//
//- (void)willExitFullscreen
//{
//    NSLog(@"willExitFullscreen");
//    [self back];
//}

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
    }];
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
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //
        self.player.view.frame = frame;
        
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

- (void)back
{
    if ( UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    } else {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
    }
}

@end
