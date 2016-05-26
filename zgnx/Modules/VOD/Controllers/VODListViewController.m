//
//  VODListViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VODListViewController.h"
#import "Defines.h"
#import "CatalogService.h"
#import "PagerTabStripper.h"
#import "VideoListViewController.h"

@interface VODListViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, copy) NSArray* catalogs;

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, weak) PagerTabStripper* tabStripper;

@property (nonatomic, assign) NSInteger currentPageIndex;

@end
@implementation VODListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        [self createTabBarItemWithTitle:@"推荐"
                                  image:nil
                          selectedImage:nil
                    titleTextAttributes:@{ NSFontAttributeName : AWSystemFontWithSize(16, NO) }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PagerTabStripper* stripper = [[PagerTabStripper alloc] init];
    [self.contentView addSubview:stripper];
    stripper.center = CGPointMake(CGRectGetWidth(stripper.bounds) / 2,
                                  CGRectGetHeight(stripper.bounds) / 2);

    self.tabStripper = stripper;
    
    __weak typeof(self) weakSelf = self;
    self.tabStripper.didSelectBlock = ^(PagerTabStripper* stripper, NSUInteger index) {
        [weakSelf setPageIndex:index animated:YES];
    };
    
    [[CatalogService sharedInstance] loadCatalogsWithCompletion:^(id results, NSError *error) {
//        NSLog(@"%@ -> %@", results, error);
        NSMutableArray* temp = [NSMutableArray array];
        for (id dict in results[@"data"]) {
            [temp addObject:dict[@"name"]];
        }
        stripper.titles = temp;
        
        self.catalogs = results[@"data"];
        
        [self addVideoListForPages];
    }];
}

- (void)addVideoListForPages
{
    self.pageViewController =
    [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                    navigationOrientation:0
                                                  options:nil];
    [self addChildViewController:self.pageViewController];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate   = self;
    
    CGRect frame = self.contentView.bounds;
    frame.origin.y = 40;
    frame.size.height = self.contentView.height - self.tabStripper.height - 49;
    self.pageViewController.view.frame = frame;
    
    [self.contentView addSubview:self.pageViewController.view];
    
    [self setPageIndex:0 animated:NO];
}

- (void)setPageIndex:(NSUInteger)index animated:(BOOL)animated
{
    if ( index >= self.catalogs.count ) {
        return;
    }
    
    self.currentPageIndex = index;
    
    NSString* catalogID = [[self.catalogs objectAtIndex:index] objectForKey:@"id"];
    [self.pageViewController setViewControllers:@[[VideoListViewController videoListVCForPageIndex:index forCatalogID:catalogID]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:animated
                                     completion:nil];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
  
    VideoListViewController* vlvc = (VideoListViewController *)viewController;
//    NSInteger index = vlvc.pageIndex - 1;
//    if ( index < 0 ) {
//        return nil;
//    }
//    
//    NSLog(@"before pageIndex: %d", vlvc.pageIndex);
//    self.currentPageIndex = index;
//
    NSInteger index = vlvc.pageIndex - 1;
    if ( index < 0 ) {
        return nil;
    }
    
    NSString* catalogID = [[[self.catalogs objectAtIndex:index] objectForKey:@"id"] description];
//
//    NSLog(@"catalogID: %@", catalogID);
    
    VideoListViewController* newVC = [VideoListViewController videoListVCForPageIndex:index
                                                                         forCatalogID:catalogID];
    newVC.view.frame = pageViewController.view.bounds;
    return newVC;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    VideoListViewController* vlvc = (VideoListViewController *)viewController;
    
    NSInteger index = vlvc.pageIndex + 1;
    if ( index > self.catalogs.count - 1 ) {
        return nil;
    }
    
//
//    NSLog(@"after pageIndex: %d",index);
//    
////    self.currentPageIndex = index;
//    
    NSString* catalogID = [[[self.catalogs objectAtIndex:index] objectForKey:@"id"] description];
////    NSLog(@"%@ -> vlvc.pageIndex: %d", viewController, vlvc.pageIndex);
//    NSLog(@"catalogID: %@", catalogID);
    
    VideoListViewController* newVC = [VideoListViewController videoListVCForPageIndex:vlvc.pageIndex + 1
                                                                         forCatalogID:catalogID];
    newVC.view.frame = pageViewController.view.bounds;
    return newVC;//[VideoListViewController videoListVCForPageIndex:index forCatalogID:catalogID];
}

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if ( completed ) {
        VideoListViewController* currentVC = (VideoListViewController *)[[pageViewController viewControllers] firstObject];
        [self.tabStripper setSelectedIndex:currentVC.pageIndex animated:YES];
    }
}

@end
