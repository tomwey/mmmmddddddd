//
//  HotSearchView.m
//  zgnx
//
//  Created by tangwei1 on 16/6/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "HotSearchView.h"
#import "Defines.h"

@interface HotSearchView () <APIManagerDelegate>

@property (nonatomic, assign) NSUInteger rows;
@property (nonatomic, assign) NSUInteger columns;

@property (nonatomic, strong) APIManager* apiManager;

@property (nonatomic, copy) void (^completionCallback)(HotSearchView *view);
@property (nonatomic, copy) void (^selectCallback)(id selectItem);

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* errorLabel;

@property (nonatomic, strong) NSArray* dataSource;

@end
@implementation HotSearchView

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    self = [super init];
    if ( !self ) return nil;
    
    self.rows = rows;
    self.columns = columns;
    
    [self setup];
    
    return self;
}

- (void)setup
{
    self.titleLabel = AWCreateLabel(CGRectZero,
                                    @"大家都在搜",
                                    NSTextAlignmentLeft,
                                    nil,
                                    nil);
    [self addSubview:self.titleLabel];
}

- (void)dealloc
{
    self.completionCallback = nil;
    self.selectCallback     = nil;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public methods
//////////////////////////////////////////////////////////////////////////////////////
- (void)startLoading:(void (^)(HotSearchView *view))completion selectCallback:(void (^)(id selectItem))selectCallback
{
    self.completionCallback = completion;
    self.selectCallback     = selectCallback;
    
    if ( !self.apiManager ) {
        self.apiManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.apiManager sendRequest:APIRequestCreate(API_HOT_KEYWORDS,
                                                  RequestMethodGet,
                                                  @{ @"size": @(self.rows * self.columns),
                                                     @"type": @(self.videoType),
                                                    })];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark - APIManagerDelegate
//////////////////////////////////////////////////////////////////////////////////////
/** 网络请求开始 */
- (void)apiManagerDidStart:(APIManager *)manager
{
    
}

/** 网络请求完成 */
- (void)apiManagerDidFinish:(APIManager *)manager
{
    if ( self.completionCallback ) {
        self.completionCallback(self);
    }
}

/** 网络请求成功回调 */
- (void)apiManagerDidSuccess:(APIManager *)manager
{
    NSArray* data = [[manager fetchDataWithReformer:nil] objectForKey:@"data"];
    if ( [data count] > 0 ) {
        [self handleData:data];
    } else {
        [self handleEmptyDataOrError:@"Oops, 没有数据！"];
    }
}

/** 网络请求失败回调 */
- (void)apiManagerDidFailure:(APIManager *)manager
{
    [self handleEmptyDataOrError:@"加载失败，请重试"];
}

#pragma mark - getters and setters
- (UILabel *)errorLabel
{
    if ( !_errorLabel ) {
        _errorLabel = AWCreateLabel(CGRectMake(0, 0, 120, 30),
                                    nil,
                                    NSTextAlignmentCenter, nil, AWColorFromRGB(137, 137, 137));
        [self addSubview:_errorLabel];
        _errorLabel.hidden = YES;
    }
    
    [self bringSubviewToFront:_errorLabel];
    
    return _errorLabel;
}

#pragma mark - private methods
- (void)handleData:(NSArray *)data
{
    self.dataSource = data;
    
    NSInteger cols = self.columns;
    NSInteger rows = [self calcuRowsForRecordsCount:[data count]];
    
    // 临时的大小
    self.bounds = CGRectMake(0, 0, self.superview.width, 60);
    
    self.titleLabel.frame = CGRectMake(10, 5, 120, 30);
    
    for (int i=0; i<rows; i++) {
        if ( i == rows - 1 ) {
            // 计算最后一行的列数
            cols = [data count] - self.columns * (rows - 1);
        }
        for (int j=0; j<cols; j++) {
            NSInteger index = i * cols + j;
            UILabel* kwLabel = (UILabel *)[self viewWithTag:100 + index];
            if ( !kwLabel ) {
                kwLabel = AWCreateLabel(CGRectMake(0, 0, ( self.width - (self.columns + 1) * self.titleLabel.left ) / 2, 30),
                                        nil,
                                        NSTextAlignmentLeft,
                                        nil,
                                        AWColorFromRGB(137, 137, 137));
                [self addSubview:kwLabel];
                kwLabel.adjustsFontSizeToFitWidth = YES;
                kwLabel.tag = 100 + index;
                kwLabel.userInteractionEnabled = YES;
                
                UIButton* btn = AWCreateImageButton(nil, self, @selector(btnClicked:));
                [kwLabel addSubview:btn];
                btn.frame = kwLabel.bounds;
            }
            
            id item = nil;
            if ( index < [data count] ) {
                item = data[index];
            }
            
            kwLabel.text = item[@"keyword"];
            NSInteger m = j % cols;
            kwLabel.position = CGPointMake(self.titleLabel.left + ( kwLabel.width + self.titleLabel.left ) * m,
                                           self.titleLabel.bottom + 10 + ( kwLabel.height + self.titleLabel.left ) * i);
            
            if ( i == rows - 1 ) {
                // 重新计算高度
                self.height = kwLabel.bottom + 10;
            }
            
        }
    }
}

- (void)btnClicked:(UIButton *)sender
{
    NSInteger index = sender.superview.tag - 100;
    if ( self.selectCallback ) {
        if (index < [self.dataSource count]) {
            self.selectCallback([self.dataSource objectAtIndex:index]);
        }
    }
}

- (NSInteger)calcuRowsForRecordsCount:(NSInteger)count
{
    NSInteger rows = 0;
    if ( self.columns != 0 ) {
        rows = ( count + self.columns - 1 ) / self.columns;
    }
    return rows;
}

- (void)handleEmptyDataOrError:(NSString *)msgTip
{
    self.errorLabel.hidden = NO;
    self.errorLabel.text   = msgTip;
    
    self.bounds = CGRectMake(0, 0, self.superview.width, 60);
    self.errorLabel.center = CGPointMake(self.width / 2, self.height / 2);
}

@end
