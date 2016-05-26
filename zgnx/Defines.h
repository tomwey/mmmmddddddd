//
//  Defines.h
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

#define API_HOST @"http://123.59.129.197/api/v1/"
#define API_VOD_TYPES @"/types"
#define API_VOD_LIST @""

#define NAV_BAR_BG_COLOR AWColorFromRGB(40, 182, 238)

// 外部组件
#import <AWMacros/AWMacros.h>
#import <AWUITools/AWUITools.h>
#import <AWAPIManager/AWAPIManager.h>
//#import <AWTableView/*.h>
#import <AWGeometry/UIView+AWGeometry.h>

// 扩展
#import "UIViewController+AWFactoryMethods.h"
#import "UIViewController+CreateTabBarItem.h"
#import "CustomNavBar.h"

#import "CTMediator.h"

// 用户模块
#import "UserModule.h"

#import "VODModule.h"

#import "LiveModule.h"

#import "VideoStreamModule.h"

#import "SearchModule.h"
#import "ViewHistoryModule.h"

// 模型
// 视图
// 控制器
//#import "LiveViewController.h"
//#import "VODListViewController.h"
//#import "UserViewController.h"

#endif /* Defines_h */
