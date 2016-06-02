//
//  SearchBar.h
//  zgnx
//
//  Created by tangwei1 on 16/6/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchBar;
@protocol SearchBarDelegate <NSObject>

@optional
- (void)searchBar:(SearchBar *)searchBar textDidChange:(NSString *)searchText;

- (BOOL)searchBarShouldBeginEditing:(SearchBar *)searchBar;
- (BOOL)searchBarShouldEndEditing:(SearchBar *)searchBar;
- (BOOL)searchBarShouldReturn:(SearchBar *)searchBar;

@end

@interface SearchBar : UIView

@property (nonatomic, weak) id <SearchBarDelegate> delegate;

@property (nonatomic, copy) NSString* text;

- (void)resignFirstResponder;

@end
