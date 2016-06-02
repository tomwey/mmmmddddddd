//
//  CommonVODListViewController.h
//  zgnx
//
//  Created by tomwey on 5/30/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "BaseNavBarViewController.h"

@class AWTableViewDataSource;
@interface CommonVODListViewController : BaseNavBarViewController

/**
 * 子类重写，并且需要调用super
 */
- (void)loadDataForPage:(NSInteger)page;
/**
 * 每一次loadDataForPage调用完成，回调一次下面的方法
 */
- (void)finishLoading:(NSArray *)result error:(NSError *)error;

@end
