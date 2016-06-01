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

@interface BannerView () <UIPageViewControllerDataSource, APIManagerDelegate>

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, strong) NSArray* dataSource;

@property (nonatomic, strong) APIManager* apiManager;

@end
@implementation BannerView

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
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.view.frame = self.bounds;
    [self addSubview:self.pageViewController.view];
    
    self.apiManager = [[APIManager alloc] initWithDelegate:self];
    
    [self.apiManager sendRequest:APIRequestCreate(API_BANNERS, RequestMethodGet, nil)];
    
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(BannerViewController *)viewController
{
    if ( viewController.pageIndex - 1 < 0 ) {
        return nil;
    }
    
    NSString* url = [[self.dataSource objectAtIndex:viewController.pageIndex - 1] objectForKey:@"image"];
    return [BannerViewController viewControllerWithPageIndex:viewController.pageIndex - 1 imageUrl:url];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(BannerViewController *)viewController
{
    if ( viewController.pageIndex + 1 > [self.dataSource count] - 1 ) {
        return nil;
    }
    
    NSString* url = [[self.dataSource objectAtIndex:viewController.pageIndex + 1] objectForKey:@"image"];
    return [BannerViewController viewControllerWithPageIndex:viewController.pageIndex + 1 imageUrl:url];
}

/** 网络请求成功回调 */
- (void)apiManagerDidSuccess:(APIManager *)manager
{
    self.dataSource = [[manager fetchDataWithReformer:nil] objectForKey:@"data"];
    
    if ( [self.dataSource count] > 0 ) {
        self.pageViewController.dataSource = self;
        NSString* url = [[self.dataSource objectAtIndex:0] objectForKey:@"image"];
        [self.pageViewController setViewControllers:@[[BannerViewController viewControllerWithPageIndex:0 imageUrl:url]]
                                          direction:UIPageViewControllerNavigationDirectionForward animated:NO
                                         completion:nil];
    }
    
}

/** 网络请求失败回调 */
- (void)apiManagerDidFailure:(APIManager *)manager
{
    
}

@end
