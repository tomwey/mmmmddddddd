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

@property (nonatomic, strong, readonly) AWTableViewDataSource* dataSource;

@end
