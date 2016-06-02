//
//  SearchResultView.m
//  zgnx
//
//  Created by tangwei1 on 16/6/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "SearchResultView.h"
#import "SearchBar.h"

@interface SearchResultView ()

@property (nonatomic, strong) UITableView* searchResultsTableView;
@property (nonatomic, strong) UIView* maskView;

@end
@implementation SearchResultView

//- (instancetype)initWithSearchBar:(SearchBar *)searchBar
//{
//    if ( self = [super initWithFrame:CGRectZero] ) {
//        self.searchBar = searchBar;
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)noti
{
    CGRect bounds = [[noti.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frame = self.searchResultsTableView.frame;
    frame.size.height = CGRectGetHeight(self.bounds) - bounds.size.height;
    self.searchResultsTableView.frame = frame;
}

- (void)setSearchResultsDataSource:(id<UITableViewDataSource>)searchResultsDataSource
{
    _searchResultsDataSource = searchResultsDataSource;
    self.searchResultsTableView.dataSource = _searchResultsDataSource;
}

- (void)setSearchResultsDelegate:(id<UITableViewDelegate>)searchResultsDelegate
{
    _searchResultsDelegate = searchResultsDelegate;
    self.searchResultsTableView.delegate = _searchResultsDelegate;
}

- (UITableView *)searchResultsTableView
{
    if ( !_searchResultsTableView ) {
        _searchResultsTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self addSubview:_searchResultsTableView];
        _searchResultsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _searchResultsTableView;
}

- (void)prepareForSearching
{
    self.maskView.hidden = NO;
    self.searchResultsTableView.hidden = YES;
}

- (void)completeSearching
{
    self.maskView.hidden = YES;
    self.searchResultsTableView.hidden = NO;
}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] init];
        [self addSubview:_maskView];
        
        _maskView.frame = self.bounds;
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = .6;
        
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    }
    return _maskView;
}

- (void)tap
{
    [self.searchBar resignFirstResponder];
    self.hidden = YES;
}

@end
