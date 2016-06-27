//
//  UploadListVideoViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/6/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UploadListVideoViewController.h"
#import "Defines.h"
#import "LoadDataService.h"

@interface UploadListVideoViewController ()

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) LoadDataService* dataService;

@end

@implementation UploadListVideoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.fromType = StreamFromTypeUploaded;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"我的上传";
    
}

/**
 * 子类重写，并且需要调用super
 */
- (void)loadDataForPage:(NSInteger)page
{
    [super loadDataForPage:page];
    
    if ( !self.dataService ) {
        self.dataService = [[LoadDataService alloc] init];
    }
    
    __weak typeof(self)weakSelf = self;
    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
    [self.dataService GET:@"/videos/uploaded"
                   params:@{
                           @"token": token,
                           @"page": @(page),
                           @"size": @(kPageSize)
                           }
               completion:^(id result, NSError *error)
    {
        [weakSelf finishLoading:[result objectForKey:@"data"] error:error];
    }];
}

@end
