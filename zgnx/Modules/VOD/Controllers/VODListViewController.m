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
#import "SwipeView.h"
#import "VODListView.h"

@interface VODListViewController () <SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, copy) NSArray* catalogs;

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, weak) PagerTabStripper* tabStripper;

@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic, strong) SwipeView* swipeView;

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
        weakSelf.swipeView.currentPage = index;
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            VODListView* listView = (VODListView *)[self.swipeView currentItemView];
            [listView startLoad];
        });
    }];
}

- (void)addVideoListForPages
{
    
    if ( !self.swipeView ) {
        self.swipeView = [[SwipeView alloc] init];
        [self.contentView addSubview:self.swipeView];
        self.swipeView.frame = CGRectMake(0, self.tabStripper.bottom,
                                          self.tabStripper.width,
                                          self.contentView.height - self.tabStripper.height - 49);
    }
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate   = self;
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.catalogs count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    VODListView* listView = nil;
//    if ( view == nil ) {
        listView = [[VODListView alloc] init];
        listView.frame = swipeView.bounds;
//    } else {
//        listView = (VODListView *)view;
//    }
    
    listView.catalogID = [[[self.catalogs objectAtIndex:index] objectForKey:@"id"] description];
    
    return listView;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self.tabStripper setSelectedIndex:swipeView.currentPage animated:YES];
    
    VODListView* listView = (VODListView*)[swipeView currentItemView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [listView startLoad];
    });
    
}

@end
