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
#define API_VOD_TYPES              @"/types"
#define API_VOD_LIST               @"/videos"
#define API_USER_SIGNUP            @"/account/signup"
#define API_USER_LOGIN             @"/account/login"
#define API_USER_LOAD_PROFILE      @"/user/me"
#define API_USER_UPDATE_AVATAR     @"/user/update_avatar"
#define API_USER_UPDATE_NICKNAME   @"/user/update_nickname"
#define API_LIVING_VIDOES          @"/live/channels"
#define API_HOT_LIVED_VIDEOS       @"/live/hot_videos"
#define API_SEND_FEEDBACK          @"/feedbacks"
#define API_USER_CODE              @"/auth_codes"
#define API_USER_UPDATE_PASSWORD   @"/user/update_password"
#define API_USER_LIKED_VIDEOS      @"/user/favorites"
#define API_BANNERS                @"/banners"
#define API_HOT_KEYWORDS           @"/search/hot_keywords"
#define API_VIDEOS_MORE_LIKED      @"/videos/more_liked"
#define API_HOT_SEARCHES           @"/hot_searches"
#define API_KEYWORDS_LIST          @"/search/kw_list"
#define API_SEARCH_VIDEOS          @"/search"
#define API_VIEW_HISTORY_CREATE    @"/view_histories/create"
#define API_VIEW_HISTORY_DELETE    @"/view_histories/delete"
#define API_VIEW_HISTORY_LIST      @"/view_histories"
#define API_USER_LIKE              @"/user/like"
#define API_USER_CANCEL_LIKE       @"/user/cancel_like"
#define API_USER_FAVORITE          @"/user/favorite"
#define API_USER_CANCEL_FAVORITE   @"/user/cancel_favorite"
#define API_BILI                   @"/bilibilis"
#define API_SEND_BILI              @"/bilibilis"
#define API_GRANT_SENT             @"/grants/sent"
#define API_GRANT_RECEIPT          @"/grants/receipt"
#define API_USER_GRANT             @"/grants"

#define NAV_BAR_BG_COLOR AWColorFromRGB(40, 182, 238)
#define MAIN_BLUE_COLOR  NAV_BAR_BG_COLOR
#define BG_COLOR_GRAY    AWColorFromRGB(240, 240, 240)
#define TABBAR_TITLE_SELECTED_COLOR AWColorFromRGB(20, 118, 255)

#define kThumbLeft 10
#define kThumbTop kThumbLeft
#define kBlackToolbarAlpha 0.8

#define kPageSize 10

#define kAboutPageURL @"http://123.59.129.197/p/about"

// 外部组件
#import <AWMacros/AWMacros.h>
#import <AWUITools/AWUITools.h>
#import <AWAPIManager/AWAPIManager.h>
//#import <AWTableView/*.h>
#import <AWGeometry/UIView+AWGeometry.h>
#import <AWTableView/UITableView+RemoveBlankCells.h>
#import <AWTableView/AWTableViewDataSource.h>
#import <AWTableView/UITableView+LoadEmptyOrErrorHandle.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIImageView+AFNetworking.h"
//#import "NSData+AES.h"

#import "DMS.h"

// 扩展
#import "UIViewController+AWFactoryMethods.h"
#import "UIViewController+CreateTabBarItem.h"
#import "CustomNavBar.h"
#import "UITableView+RefreshControl.h"

#import "LoadMoreView.h"
#import "AWModalAlert.h"
#import <AWRefresh/UIScrollView+AWRefresh.h>
#import "SimpleToast.h"

#import "CTMediator.h"

#import "Toast.h"

#import "UserService.h"

#import "Stream.h"
#import "StreamTable.h"

// 用户模块
#import "UserModule.h"

#import "VODModule.h"

#import "LiveModule.h"

#import "VideoStreamModule.h"

#import "SearchModule.h"
#import "ViewHistoryModule.h"

// 模型
// 视图
#import "CustomTextField.h"

#endif /* Defines_h */
