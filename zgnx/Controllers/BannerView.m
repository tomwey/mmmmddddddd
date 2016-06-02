//
//  BannerView.m
//  zgnx
//
//  Created by tomwey on 6/2/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "BannerView.h"
#import "Defines.h"

@interface BannerViewController : UIViewController

+ (instancetype)viewControllerWithPageIndex:(NSInteger)pageIndex imageUrl:(NSString *)url;

@property (nonatomic, assign, readonly) NSInteger pageIndex;

@end

@interface BannerViewController ()

@property (nonatomic, assign, readwrite) NSInteger pageIndex;
@property (nonatomic, copy) NSString* imageUrl;

@end
@implementation BannerViewController

+ (instancetype)viewControllerWithPageIndex:(NSInteger)pageIndex imageUrl:(NSString *)url
{
    return [[self alloc] initWithPageIndex:pageIndex imageUrl:url];
}

- (instancetype)initWithPageIndex:(NSUInteger)index imageUrl:(NSString *)url
{
    if ( self = [super init] ) {
        self.pageIndex = index;
        self.imageUrl = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView* imageView = AWCreateImageView(nil);
    [self.view addSubview:imageView];
    imageView.frame = self.view.bounds;
    imageView.backgroundColor = [UIColor grayColor];
    
    imageView.image = nil;
    
    [imageView setImageWithURL:[NSURL URLWithString:self.imageUrl]];
}

@end

@interface BannerView () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, APIManagerDelegate>

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, strong) NSArray*              dataSource;
@property (nonatomic, strong) APIManager*           apiManager;
@property (nonatomic, strong) UIPageControl*        pageControl;
@property (nonatomic, strong) NSTimer*              scrollTimer;

@property (nonatomic, copy)   void (^didSelectItem)(id selectItem);

@property (nonatomic, strong) UIActivityIndicatorView* spinner;

@end
@implementation BannerView

#define kAutoScrollInterval 3.0

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.frame = CGRectMake(0, 0, AWFullScreenWidth(),AWFullScreenWidth() * 0.382);
    
    // 分页视图
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.view.frame = self.bounds;
    [self addSubview:self.pageViewController.view];
    self.pageViewController.delegate = self;
    
    // 分页指示器
    self.pageControl = [[UIPageControl alloc] init];
    [self addSubview:self.pageControl];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.frame = CGRectMake(0, 0, self.width, 20);
    self.pageControl.y = self.height - 25;
    self.pageControl.currentPageIndicatorTintColor = NAV_BAR_BG_COLOR;
    
    // 加载进度
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:self.spinner];
    self.spinner.center = CGPointMake(self.width / 2, self.height / 2);
    
    // 单击手势
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    
    // 自动轮播定时器
    self.scrollTimer = [NSTimer timerWithTimeInterval:kAutoScrollInterval
                                               target:self
                                             selector:@selector(autoScroll)
                                             userInfo:nil
                                              repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.scrollTimer forMode:NSRunLoopCommonModes];
    [self.scrollTimer setFireDate:[NSDate distantFuture]];
}

- (void)dealloc
{
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
    self.didSelectItem = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public methods
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startLoading:(void (^)(id selectItem))callback
{
    self.didSelectItem = callback;
    
    if ( !self.apiManager ) {
        self.apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    if ([self.spinner isAnimating] == NO) {
        [self.spinner startAnimating];
    }
    [self.apiManager sendRequest:APIRequestCreate(API_BANNERS, RequestMethodGet, nil)];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIPageViewController dataSource
////////////////////////////////////////////////////////////////////////////////////////////////////
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
               viewControllerBeforeViewController:(BannerViewController *)viewController
{
    NSInteger index = viewController.pageIndex - 1;
    if ( index < 0 ) {
        index = [self.dataSource count] - 1;
    }

    NSString* url = [[self.dataSource objectAtIndex:index] objectForKey:@"image"];
    return [BannerViewController viewControllerWithPageIndex:index imageUrl:url];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
                viewControllerAfterViewController:(BannerViewController *)viewController
{
    NSInteger index = viewController.pageIndex + 1;
    if ( index > [self.dataSource count] - 1 ) {
        index = 0;
    }
    
    NSString* url = [[self.dataSource objectAtIndex:index] objectForKey:@"image"];
    return [BannerViewController viewControllerWithPageIndex:index imageUrl:url];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIPageViewController delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
     - (void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    // 暂停自动滚动
    [self.scrollTimer setFireDate:[NSDate distantFuture]];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if ( completed ) {
        // 启动自动滚动
        [self.scrollTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kAutoScrollInterval]];
        
        BannerViewController* bvc = [pageViewController.viewControllers firstObject];
        self.pageControl.currentPage = bvc.pageIndex;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - APIManager delegate
////////////////////////////////////////////////////////////////////////////////////////////////////
/** 网络请求成功回调 */
- (void)apiManagerDidSuccess:(APIManager *)manager
{
    self.dataSource = [[manager fetchDataWithReformer:nil] objectForKey:@"data"];
    
    if ( [self.dataSource count] > 0 ) {
        self.pageViewController.dataSource = self;
        
        // 3。0后启动定时器
        [self.scrollTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kAutoScrollInterval]];
        
        // 滚动到第一页
        [self scrollToPage:0 animated:NO];
    }
    
}

/** 网络请求失败回调 */
- (void)apiManagerDidFailure:(APIManager *)manager
{
    NSLog(@"Error: %@", manager.apiError);
}

- (void)apiManagerDidFinish:(APIManager *)manager
{
    [self.spinner stopAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSTimer target - action 
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)autoScroll
{
    NSInteger nextPage = self.pageControl.currentPage + 1;
    if ( nextPage > self.dataSource.count - 1 ) {
        nextPage = 0;
    }
    
    [self scrollToPage:nextPage animated:YES];
}

- (void)tap
{
    if ( self.didSelectItem ) {
        id obj = nil;
        if ( self.pageControl.currentPage < [self.dataSource count] ) {
            obj = self.dataSource[self.pageControl.currentPage];
        }
        self.didSelectItem(obj);
        self.didSelectItem = nil;
    }
}

- (void)scrollToPage:(NSInteger)pageIndex animated:(BOOL)animated
{
    self.pageControl.numberOfPages = [self.dataSource count];
    
    self.pageControl.currentPage = pageIndex;
    
    NSString* url = [[self.dataSource objectAtIndex:pageIndex] objectForKey:@"image"];
    [self.pageViewController setViewControllers:@[[BannerViewController viewControllerWithPageIndex:pageIndex
                                                                                           imageUrl:url]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:animated
                                     completion:nil];
}

@end
