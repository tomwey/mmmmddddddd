//
//  UploadFinalViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/6/22.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UploadFinalViewController.h"
#import "Defines.h"
#import "LoadDataService.h"

@interface UploadFinalViewController () <UITextViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) NSString *filename;

@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView  *bodyView;

@property (nonatomic, strong) UILabel     *textViewPlaceholderLabel;

@property (nonatomic, strong) LoadDataService *loadService;

@property (nonatomic, strong) UIWebView *uploadIntroView;

@end

@implementation UploadFinalViewController

- (instancetype)initWithCoverImage:(UIImage *)coverImage fileName:(NSString *)filename
{
    if ( self = [super init] ) {
        self.coverImage = coverImage;
        self.filename   = filename;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"视频简介";
    
    self.contentView.backgroundColor = BG_COLOR_GRAY;//[UIColor whiteColor];
    
    self.navBar.rightItem = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
                                               @"保存",
                                               [UIColor whiteColor],
                                               self,
                                               @selector(save));
    
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(20,
                                                                    20,
                                                                    self.contentView.width - 40, 34)];
    [self.contentView addSubview:self.titleField];
    self.titleField.placeholder = @" 视频标题（必填）";
    self.titleField.layer.borderColor = [AWColorFromRGB(201, 201, 201) CGColor];
    self.titleField.layer.borderWidth = 1;
    
    self.bodyView = [[UITextView alloc] initWithFrame:self.titleField.frame];
    self.bodyView.height = 120;
    [self.contentView addSubview:self.bodyView];
    self.bodyView.top = self.titleField.bottom + 20;
    
    self.bodyView.backgroundColor = [UIColor clearColor];
    
    self.bodyView.layer.borderColor = self.titleField.layer.borderColor;
    self.bodyView.layer.borderWidth = 1;
    
    self.bodyView.font = self.titleField.font;
    
    self.textViewPlaceholderLabel = AWCreateLabel(self.bodyView.frame,
                                              @"视频简介",
                                              NSTextAlignmentLeft,
                                              nil,
                                              AWColorFromRGB(201, 201, 201));
    [self.contentView addSubview:self.textViewPlaceholderLabel];
    self.textViewPlaceholderLabel.height = 34;
    self.textViewPlaceholderLabel.left  += 6;
    
    self.bodyView.delegate = self;
    
    [self.uploadIntroView loadRequest:[NSURLRequest requestWithURL:
                                       [NSURL URLWithString:@"http://yaying.tv/p/upload_detail"]]];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.textViewPlaceholderLabel.hidden = [textView.text length] > 0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [self.titleField resignFirstResponder];
    
    [self.bodyView resignFirstResponder];
}

- (void)save
{
    NSString *title = [self.titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ( [title length] == 0 ) {
        [SimpleToast showText:@"视频标题不能为空"];
        return;
    }
    
    [self.titleField resignFirstResponder];
    [self.bodyView resignFirstResponder];
    
    if ( !self.loadService ) {
        self.loadService = [[LoadDataService alloc] init];
    }
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
    [self.loadService POST:@"/videos"
                    params:@{
                               @"token": token,
                               @"title": title,
                               @"body": self.bodyView.text ?: @"",
                               @"cover_image": UIImageJPEGRepresentation(self.coverImage, 0.9),
                               @"filename": self.filename ?: @"",
                               @"category_id": [[NSUserDefaults standardUserDefaults] objectForKey:@"upload.cid"] ?: @(-1),
                            }
                completion:^(id result, NSError *error)
    {
        [MBProgressHUD hideHUDForView:self.contentView animated:YES];
        if ( error ) {
            [[Toast showText:error.domain] setBackgroundColor:NAV_BAR_BG_COLOR];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

- (UIWebView *)uploadIntroView
{
    if ( !_uploadIntroView ) {
        _uploadIntroView = [[UIWebView alloc] init];
        [self.contentView addSubview:_uploadIntroView];
        _uploadIntroView.scalesPageToFit = YES;
        _uploadIntroView.backgroundColor = BG_COLOR_GRAY;
        _uploadIntroView.frame = CGRectMake(0, self.bodyView.bottom + 20,
                                            self.contentView.width,
                                            self.contentView.height - self.bodyView.bottom - 20);
    }
    return _uploadIntroView;
}


@end
