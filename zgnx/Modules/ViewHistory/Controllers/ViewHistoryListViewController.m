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

@end
@implementation ViewHistoryListViewController

- (instancetype)initWithAuthToken:(NSString *)authToken
{
    if ( self = [super init] ) {
        self.fromType = StreamFromTypeHistory;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"历史记录";
}

- (BOOL)removeStream:(Stream *)aStream
{
    if ( !self.vhService ) {
        self.vhService = [[ViewHistoryService alloc] init];
    }
    
    return [self.vhService deleteRecord:aStream needSyncServer:YES];
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
                                NSMutableArray *temp = [NSMutableArray array];
                                [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    Stream *stream = nil;
                                    if ( [obj isKindOfClass:[NSDictionary class]] ) {
                                        
                                        stream = [[Stream alloc] initWithDictionary:obj[@"video"]];
                                        stream.currentPlaybackTime = [obj[@"play_progress"] description];
                                    } else {
                                        stream = (Stream *)obj;
                                    }
//                                    Stream *stream = (Stream *)obj;
                                    stream.isEditing = weakSelf.isEditing;
                                    [temp addObject:stream];
                                }];
                                [weakSelf finishLoading:temp error:error];
                            }];
}

@end
