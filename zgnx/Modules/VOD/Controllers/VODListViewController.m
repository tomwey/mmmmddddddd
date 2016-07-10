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
#import "BannerPageViewController.h"
#import "LoadDataService.h"

@interface VODListViewController () <SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, copy) NSArray*          catalogs;
@property (nonatomic, weak) PagerTabStripper* tabStripper;
@property (nonatomic, strong) SwipeView*      swipeView;

@property (nonatomic, strong) LoadDataService *loadStreamService;

@end

@implementation VODListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        
        [self createTabBarItemWithTitle:@"推荐"
                                  image:[UIImage imageNamed:@"tab_ranked_n.png"]
                          selectedImage:[UIImage imageNamed:@"tab_ranked_s.png"]
           titleTextAttributesForNormal:nil
         titleTextAttributesForSelected:@{ NSForegroundColorAttributeName: TABBAR_TITLE_SELECTED_COLOR }];
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
    stripper.backgroundColor = [UIColor whiteColor];///AWColorFromRGB(251, 251, 251);

    self.tabStripper = stripper;
    
    stripper.selectedColor = NAV_BAR_BG_COLOR;
    stripper.titleAttributes = @{ NSForegroundColorAttributeName: AWColorFromRGB(186, 186, 186),
                                  NSFontAttributeName: AWSystemFontWithSize(16, NO) };
    
    __weak typeof(self) weakSelf = self;
    self.tabStripper.didSelectBlock = ^(PagerTabStripper* stripper, NSUInteger index) {
        weakSelf.swipeView.currentPage = index;
    };
    
    // 翻页视图
    if ( !self.swipeView ) {
        self.swipeView = [[SwipeView alloc] init];
        [self.contentView addSubview:self.swipeView];
        self.swipeView.frame = CGRectMake(0,
                                          self.tabStripper.bottom,
                                          self.tabStripper.width,
                                          self.contentView.height - self.tabStripper.height - 49);
        
        self.swipeView.delegate = self;
        
        self.swipeView.backgroundColor = BG_COLOR_GRAY;
    }
    
    [[CatalogService sharedInstance] loadCatalogsWithCompletion:^(id results, NSError *error) {
//        NSLog(@"%@ -> %@", results, error);
        NSMutableArray* temp = [NSMutableArray array];
        for (id dict in results[@"data"]) {
            [temp addObject:dict[@"name"]];
        }
        if ( [temp count] > 0 ) {
            stripper.titles = temp;
        }
        
        self.catalogs = results[@"data"];

        [self addVideoListForPages];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self swipeStartLoad];
        });
    }];
    
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
//    id cellData = [noti.object cellData];
    Stream *stream = [noti.object stream];
    stream.fromType = StreamFromTypeDefault;
    
    UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openVideoStreamVCWithStream:stream];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)swipeStartLoad
{
    VODListView* listView = (VODListView *)[self.swipeView currentItemView];
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    [listView startLoadForPage:1 completion:^(BOOL succeed) {
        [MBProgressHUD hideAllHUDsForView:self.contentView animated:YES];
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
    listView = [[VODListView alloc] init];
    listView.backgroundColor = BG_COLOR_GRAY;
    listView.frame = swipeView.bounds;
    
    listView.catalogID = [[[self.catalogs objectAtIndex:index] objectForKey:@"id"] description];
    
    listView.reloadBlock = ^(BOOL succeed) {
        if ( succeed ) {
            [MBProgressHUD hideAllHUDsForView:self.contentView animated:YES];
        } else {
            [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
        }
    };
    
    listView.didClickBannerBlock = ^(id bannerInfo) {
//        NSLog(@"banner info: %@", bannerInfo);
        [self openBanner:bannerInfo];
    };
    
    return listView;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self.tabStripper setSelectedIndex:swipeView.currentPage animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self swipeStartLoad];
    });
    
}

- (void)openBanner:(id)bannerInfo
{
    NSString *link = bannerInfo[@"link"];
    
    if ( [link hasPrefix:@"http"] ) {
        // 网页广告
        BannerPageViewController *vc = [[BannerPageViewController alloc] init];
        vc.adLink = link;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        // 连接到一个视频
        [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
        
        __weak typeof(self) me = self;
        NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
        NSString *uri = [NSString stringWithFormat:@"/streams/%@", link];
        [self.loadStreamService GET:uri
                             params:@{
                                      @"token": token
                                      } completion:^(id result, NSError *error) {
                                          [MBProgressHUD hideHUDForView:me.contentView animated:YES];
                                          
                                          if ( error ) {
                                              [SimpleToast showText:@"打开视频失败！"];
                                          } else {
                                              Stream *stream = [[Stream alloc] initWithDictionary:result[@"data"]];
                                              
                                              if ( [stream.stream_id length] == 0 ) {
                                                  [SimpleToast showText:@"没有该视频！"];
                                              } else {
                                                  UIViewController *vc = [[CTMediator sharedInstance] CTMediator_openVideoStreamVCWithStream:stream];
                                                  [me presentViewController:vc animated:YES completion:nil];
                                              }
                                          }
                                      }];
    }
}

- (LoadDataService *)loadStreamService
{
    if ( !_loadStreamService ) {
        _loadStreamService = [[LoadDataService alloc] init];
    }
    return _loadStreamService;
}

@end
