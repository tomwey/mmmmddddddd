//
//  AboutViewController.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "AboutViewController.h"
#import "Defines.h"

@interface AboutViewController () <UIWebViewDelegate>

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navBar.title = @"关于";
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:webView];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kAboutPageURL]]];
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

@end
