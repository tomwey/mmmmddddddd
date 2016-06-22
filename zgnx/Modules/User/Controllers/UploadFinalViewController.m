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

@interface UploadFinalViewController ()

@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) NSString *filename;

@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView  *bodyView;

@property (nonatomic, strong) LoadDataService *loadService;

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
    
    self.navBar.rightItem = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
                                               @"保存",
                                               [UIColor whiteColor],
                                               self,
                                               @selector(save));
    
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(20,
                                                                    20,
                                                                    self.contentView.width - 40, 34)];
    [self.contentView addSubview:self.titleField];
    self.titleField.placeholder = @" 输入视频标题（必填）";
    self.titleField.layer.borderColor = [AWColorFromRGB(137,137,137) CGColor];
    self.titleField.layer.borderWidth = 1;
    
    self.bodyView = [[UITextView alloc] initWithFrame:self.titleField.frame];
    self.bodyView.height = 120;
    [self.contentView addSubview:self.bodyView];
    self.bodyView.top = self.titleField.bottom + 20;
    
    self.bodyView.backgroundColor = [UIColor clearColor];
    
    self.bodyView.layer.borderColor = self.titleField.layer.borderColor;
    self.bodyView.layer.borderWidth = 1;
}

- (void)save
{
    [self.titleField resignFirstResponder];
    [self.bodyView resignFirstResponder];
    
    if ( self.loadService ) {
        self.loadService = [[LoadDataService alloc] init];
    }
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
    [self.loadService POST:@"/videos"
                    params:@{
                               @"token": token,
                               @"title": self.titleField.text ?: @"",
                               @"body": self.bodyView.text ?: @"",
                               @"cover_image": UIImageJPEGRepresentation(self.coverImage, 0.9),
                               @"filename": self.filename ?: @""
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


@end
