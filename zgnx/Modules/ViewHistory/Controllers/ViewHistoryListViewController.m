//
//  ViewHistoryListViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "ViewHistoryListViewController.h"
#import "Defines.h"
#import "ViewHistoryService.h"
#import "VideoCell.h"

@interface ViewHistoryListViewController ()

@property (nonatomic, strong) ViewHistoryService *vhService;
@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, assign) BOOL isEditing;

@end
@implementation ViewHistoryListViewController

- (instancetype)initWithAuthToken:(NSString *)authToken
{
    if ( self = [super init] ) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fromType = StreamFromTypeHistory;
    
    self.navBar.title = @"历史记录";
    
    self.editButton = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
                                         @"编辑",
                                         [UIColor whiteColor],
                                         self,
                                         @selector(edit));
    self.navBar.rightItem = self.editButton;
}

- (BOOL)removeStream:(Stream *)aStream
{
    if ( !self.vhService ) {
        self.vhService = [[ViewHistoryService alloc] init];
    }
    
    return [self.vhService deleteRecord:aStream needSyncServer:YES];
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

/**
 * 子类重写，并且需要调用super
 */
- (void)loadDataForPage:(NSInteger)page
{
    [super loadDataForPage:page];
    
    if ( !self.vhService ) {
        self.vhService = [[ViewHistoryService alloc] init];
    }
    
    __weak typeof(self)weakSelf = self;
    [self.vhService loadRecordsForUser:[[UserService sharedInstance] currentUser]
                                  page:page
                            completion:^(id result, NSError *error) {
                                [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    Stream *stream = (Stream *)obj;
                                    stream.isEditing = weakSelf.isEditing;
                                }];
                                [weakSelf finishLoading:result error:error];
                            }];
}

@end
