//
//  BannerPageViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/6/27.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "BannerPageViewController.h"
#import "Defines.h"

@interface BannerPageViewController () <UIWebViewDelegate>

@end

@implementation BannerPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"广告";
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:webView];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.adLink]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self.contentView animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    [MBProgressHUD hideHUDForView:self.contentView animated:YES];
    
    [[Toast showText:@"Oops, 加载失败了！"] setBackgroundColor:NAV_BAR_BG_COLOR];
}

- (BOOL)           webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
            navigationType:(UIWebViewNavigationType)navigationType
{
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        NSString *url = [request.URL absoluteString];
        if ( [url hasPrefix:@"zglytv://upload"] ) {
            // 打开上传页面
            NSString *cidPair = [[url componentsSeparatedByString:@"?"] lastObject];
            NSString *cid = [[cidPair componentsSeparatedByString:@"="] lastObject];
            
            if ( cid ) {
                [[NSUserDefaults standardUserDefaults] setObject:cid forKey:@"upload.cid"];
            }
            
            UIViewController *vc = [[CTMediator sharedInstance] CTMediator_openUploadVCWithAuthToken:nil];
            [self.navigationController pushViewController:vc animated:YES];
            return NO;
        }
    }
    return YES;
}

@end
