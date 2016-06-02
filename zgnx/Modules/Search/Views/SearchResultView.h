//
//  SearchResultView.h
//  zgnx
//
//  Created by tangwei1 on 16/6/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchBar;
@interface SearchResultView : UIView

//- (instancetype)initWithSearchBar:(SearchBar *)searchBar;

@property (nonatomic, weak) SearchBar* searchBar;

@property (nonatomic, strong, readonly) UITableView* searchResultsTableView;

@property (nonatomic, weak) id <UITableViewDataSource> searchResultsDataSource;
@property (nonatomic, weak) id <UITableViewDelegate> searchResultsDelegate;

- (void)prepareForSearching;
- (void)completeSearching;

@end
