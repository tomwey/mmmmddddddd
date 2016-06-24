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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"我的上传";
    
//    self.editButton = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
//                                         @"编辑",
//                                         [UIColor whiteColor],
//                                         self,
//                                         @selector(edit));
//    self.navBar.rightItem = self.editButton;
}

- (void)edit
{
    if ( [[self.editButton currentTitle] isEqualToString:@"编辑"] ) {
        [self.editButton setTitle:@"完成" forState:UIControlStateNormal];
        self.isEditing = YES;
        [self doEdit];
    } else {
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        self.isEditing = NO;
        [self done];
    }
}

- (void)doEdit
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kStartEditNotification" object:nil];
}

- (void)done
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kEndEditNotification" object:nil];
}

//- (BOOL)removeStream:(Stream *)aStream
//{
//    if ( !self.dataService ) {
//        self.dataService = [[LoadDataService alloc] init];
//    }
//}

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
