//
//  BiliView.m
//  zgnx
//
//  Created by tomwey on 6/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "BiliView.h"
#import "CustomTextField.h"
#import "Defines.h"
#import "LoadDataService.h"
#import "Bilibili.h"

@interface BiliView () <UITableViewDelegate, ReloadDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, strong) LoadDataService *loadService;
//@property (nonatomic, strong) LoadDataService *sendService;
@property (nonatomic, strong) NSMutableArray *sendServices; // 发送请求集合

@property (nonatomic, strong) CustomTextField *biliField;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, assign) BOOL allowLoading;
@property (nonatomic, assign) BOOL currentPage;

@end
@implementation BiliView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                      style:UITableViewStylePlain];
        [self addSubview:self.tableView];
        
        self.dataSource = AWTableViewDataSourceCreate(nil,
                                                      @"BiliCell",
                                                      @"bili.cell");
        self.tableView.dataSource = self.dataSource;
        self.tableView.delegate   = self;
        
        self.tableView.rowHeight = 90;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.hasNextPage  = NO;
        self.allowLoading = YES;
        self.currentPage  = 1;
        
        self.tableView.backgroundColor = BG_COLOR_GRAY;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.loadService = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.sendServices removeAllObjects];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.biliField.frame = CGRectMake(0, self.height - 37, self.width - 50, 37);
    
    self.sendButton.frame = CGRectMake(self.biliField.right + 5,
                                       self.biliField.top, 40, 37);
    
    self.tableView.frame = CGRectMake(0, 0, self.width,
                                      self.height - 37);
}

- (void)willShowKeyboard:(NSNotification *)noti
{
    CGRect frame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat top -= CGRectGetHeight(frame);
    [UIView animateWithDuration:.25 animations:^{
        self.biliField.top -= CGRectGetHeight(frame) + 5;
        self.sendButton.top -= CGRectGetHeight(frame) + 5;
    }];
}

- (void)willHideKeyboard:(NSNotification *)noti
{
    [UIView animateWithDuration:0.25 animations:^{
        self.biliField.top = self.height - 37;
        self.sendButton.top = self.height - 37;
    }];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.hasNextPage && self.allowLoading &&
        [self.dataSource.dataSource count] == indexPath.row + 1) {
        self.allowLoading = NO;
        
        self.currentPage ++;
        [self loadData];
    }
}

- (void)setStreamId:(NSString *)streamId
{
    _streamId = streamId;
    
    if ( [streamId length] > 0 ) {
        [self loadData];
    }
}

- (void)loadData
{
    [self.tableView removeErrorOrEmptyTips];
    self.tableView.hidden = YES;
    
    if ( self.loadService == nil ) {
        self.loadService = [[LoadDataService alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.loadService GET:API_BILI
                   params:@{ @"sid": _streamId ?: @"",
                             @"page": @(self.currentPage),
                             @"size": @(kPageSize),
                             }
               completion:^(id result, NSError *error)
    {
        
        [weakSelf handleResult:result error:error];
    }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    self.allowLoading = YES;
    
    if ( error ) {
        if ( self.currentPage == 1 ) {
            [self.tableView showErrorOrEmptyMessage:@"Oops, 加载出错了！点击刷新"
                                     reloadDelegate:self];
        }
        
    } else {
        NSArray *data = [result objectForKey:@"data"];
        if ( [data count] == 0 ) {
            if ( self.currentPage == 1 ) {
                [self.tableView showErrorOrEmptyMessage:@"没有消息，赶快抢沙发吧！" reloadDelegate:nil];
            }
            
        } else {
            
            self.hasNextPage = [data count] >= kPageSize;
            
            if ( self.currentPage == 1 ) {
                self.dataSource.dataSource = data;
            } else {
                NSMutableArray *temp = [NSMutableArray arrayWithArray:self.dataSource.dataSource];
                [temp addObjectsFromArray:data];
                self.dataSource.dataSource = temp;
            }
            
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        }
    }
}

- (void)reloadDataForErrorOrEmpty
{
    self.currentPage = 1;
    [self loadData];
}

- (CustomTextField *)biliField
{
    if ( !_biliField ) {
        _biliField = [[CustomTextField alloc] init];
        [self addSubview:_biliField];
        _biliField.returnKeyType = UIReturnKeyDone;
        _biliField.autocorrectionType = UITextAutocorrectionTypeNo;
        _biliField.delegate = self;
    }
    return _biliField;
}

- (UIButton *)sendButton
{
    if ( !_sendButton ) {
        _sendButton = AWCreateImageButton(nil, self, @selector(send));
        [self addSubview:_sendButton];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor blackColor]
                          forState:UIControlStateNormal];
    }
    return _sendButton;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.biliField resignFirstResponder];
    return YES;
}

- (void)send
{
    NSString *msg = [self.biliField.text stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ( [msg length] == 0 ) {
        return;
    }
    
    [self.biliField resignFirstResponder];
    self.biliField.text = @"";
    
    Bilibili *bili = [self internalAddMessage:msg];
    
    if ( self.didSendBiliBlock ) {
        self.didSendBiliBlock(self, bili);
    }
}

- (Bilibili *)internalAddMessage:(NSString *)msg
{
    User *user = [[UserService sharedInstance] currentUser];
    Bilibili *bili = [[Bilibili alloc] init];
    bili.streamId = self.streamId;
    bili.content = msg;
    
    if ( !user ) {
        bili.nickname = @"游客";
        bili.avatarUrl = @"";
    } else {
        bili.nickname = user.nickname ?: user.mobile;
        bili.avatarUrl = user.avatarUrl;
    }
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.dataSource.dataSource];
    [temp insertObject:bili atIndex:0];
    self.dataSource.dataSource = temp;
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    
    [self sendDataToServer:bili];
    
    return bili;
}

- (void)addMessage:(NSString *)msg
{
    [self internalAddMessage:msg];
}

- (void)sendDataToServer:(Bilibili *)bili
{
    if ( !self.sendServices ) {
        self.sendServices = [NSMutableArray array];
    }
    
    LoadDataService *service = [[LoadDataService alloc] init];
    [self.sendServices addObject:service];
    
    __weak typeof(self) me = self;
    [service POST:API_SEND_BILI
                    params:@{ @"content": bili.content,
                              @"stream_id": bili.streamId,
                              @"token": [[UserService sharedInstance] currentUser].authToken ?: @"",
                              }
                completion:^(id result, NSError *error) {
                    [me.sendServices removeObject:service];
                    }];
}

@end
