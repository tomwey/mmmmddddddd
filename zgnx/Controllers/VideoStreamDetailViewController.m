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
    
//    UIButton* playBtn = AWCreateTextButton(CGRectMake(0, 0, 44, 44),
//                                           @"Play",
//                                           [UIColor redColor],
//                                           self.player,
//                                           @selector(player)
//                                           );
//    [self.view addSubview:playBtn];
//    playBtn.center = self.player.view.center;
    
    UIButton* backBtn = AWCreateTextButton(CGRectMake(10, 30, 44, 44),
                                           @"返回",
                                           [UIColor redColor],
                                           self,
                                           @selector(back));
    [self.view addSubview:backBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:
     MPMoviePlayerWillEnterFullscreenNotification
                                               object:nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortraitUpsideDown;
//}

- (void)loadStateDidChange:(NSNotification *)noti
{
    NSLog(@"%@", noti.userInfo);
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
//    [self.navigationController popViewControllerAnimated:YES];
//    [self.player setFullscreen:YES animated:YES];
    
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
}

@end
