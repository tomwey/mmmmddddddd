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
#import "SwipeView.h"
#import "VODListView.h"
#import "VideoCell.h"

@interface VODListViewController () <SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, copy) NSArray* catalogs;

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, weak) PagerTabStripper* tabStripper;

@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic, strong) SwipeView* swipeView;

@property (nonatomic, strong) UIActivityIndicatorView* spinner;

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
    stripper.backgroundColor = AWColorFromRGB(251, 251, 251);

    self.tabStripper = stripper;
    
    __weak typeof(self) weakSelf = self;
    self.tabStripper.didSelectBlock = ^(PagerTabStripper* stripper, NSUInteger index) {
        weakSelf.swipeView.currentPage = index;
    };
    
    if ( !self.swipeView ) {
        self.swipeView = [[SwipeView alloc] init];
        [self.contentView addSubview:self.swipeView];
        self.swipeView.frame = CGRectMake(0, self.tabStripper.bottom,
                                          self.tabStripper.width,
                                          self.contentView.height - self.tabStripper.height - 49);
        
        self.swipeView.delegate = self;
    }
    
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
            
            [self swipeStartLoad];
        });
    }];
    
    // 进度
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.color = NAV_BAR_BG_COLOR;
    self.spinner.hidesWhenStopped = YES;
    [self.contentView addSubview:self.spinner];
    
    self.spinner.center = self.swipeView.center;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cellDidSelect:)
                                                 name:kVideoCellDidSelectNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVideoCellDidSelectNotification
                                                  object:nil];
}

- (void)cellDidSelect:(NSNotification *)noti
{
    id cellData = [noti.object cellData];
    
    UIViewController* vc =
    [[CTMediator sharedInstance] CTMediator_openVideoStreamVCWithData:cellData];
//    UINavigationController* nav = (UINavigationController*)[AWAppWindow() rootViewController];
//    [nav pushViewController:vc animated:YES];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)swipeStartLoad
{
    VODListView* listView = (VODListView *)[self.swipeView currentItemView];
    
    if ( [self.spinner isAnimating] == NO ) {
        [self.spinner startAnimating];
    }
    
    [listView startLoad:^(BOOL succeed) {
        [self.spinner stopAnimating];
    }];
}

- (void)addVideoListForPages
{
    
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
    
//    __weak typeof(self)weakSelf = self;
    listView.reloadBlock = ^(BOOL succeed) {
        if ( succeed ) {
            [self.spinner stopAnimating];
        } else {
            [self.spinner startAnimating];
        }
        
    };
    
    return listView;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self.tabStripper setSelectedIndex:swipeView.currentPage animated:YES];
    
//    VODListView* listView = (VODListView*)[swipeView currentItemView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [listView startLoad];
        [self swipeStartLoad];
    });
    
}

@end
