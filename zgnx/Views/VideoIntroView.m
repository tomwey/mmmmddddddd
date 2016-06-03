//
//  VideoIntroView.m
//  zgnx
//
//  Created by tomwey on 6/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "VideoIntroView.h"

@interface VideoIntroView () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, copy) NSString* tplContent;
@property (nonatomic, strong) UIActivityIndicatorView* spinner;

@end
@implementation VideoIntroView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.webView = [[UIWebView alloc] init];
        [self addSubview:self.webView];
        self.webView.delegate = self;
        self.webView.scalesPageToFit = YES;
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.spinner];
        self.spinner.hidesWhenStopped = YES;
    }
    return self;
}

- (void)setBody:(NSString *)bodyHTML
{
    if ( [bodyHTML length] == 0 ) {
        return;
    }
    
    NSString* html = [self.tplContent stringByReplacingOccurrencesOfString:@"{content}" withString:bodyHTML];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error;
{
    [self.spinner stopAnimating];
}

- (NSString *)tplContent
{
    if ( !_tplContent ) {
        _tplContent = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"intro.tpl" ofType:nil]
                                                      encoding:NSUTF8StringEncoding error:nil];
    }
    return _tplContent;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.webView.frame = self.bounds;
    self.spinner.center = CGPointMake(CGRectGetWidth(self.bounds) / 2,
                                      CGRectGetHeight(self.bounds) / 2);
}

@end
