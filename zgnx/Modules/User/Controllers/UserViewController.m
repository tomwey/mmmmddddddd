//
//  UserViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UserViewController.h"
#import "Defines.h"
#import "UserService.h"
#import "UserProfileView.h"
#import <AWTableView/UITableView+RemoveBlankCells.h>
#import "LoadDataService.h"

@interface UserViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* dataSource;

@property (nonatomic, copy) NSString* authToken;

@property (nonatomic, weak) UserProfileView* profileView;

@property (nonatomic, assign) BOOL needReloadUserProfile;

@end

@implementation UserViewController

- (instancetype)initWithAuthToken:(NSString *)authToken
{
    if ( self = [super init] ) {
        self.authToken = authToken;
        
        [self createTabBarItemWithTitle:@"我的"
                                  image:[UIImage imageNamed:@"tab_me_n.png"]
                          selectedImage:[UIImage imageNamed:@"tab_me_s.png"]
           titleTextAttributesForNormal:nil
         titleTextAttributesForSelected:@{ NSForegroundColorAttributeName : TABBAR_TITLE_SELECTED_COLOR }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navBar.title = @"我的";
    self.navBar.leftItem = nil;
    
    self.needReloadUserProfile = NO;
    
//    if ( [self respondsToSelector:@selector(setEdgesForExtendedLayout:)] ) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }

    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    self.tableView.height -= 49;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView removeBlankCells];
    
    UserProfileView* upv = [[UserProfileView alloc] init];
    self.tableView.tableHeaderView = upv;
    
    self.profileView = upv;
    
    self.profileView.didClickBlock = ^(UserProfileView* view) {
        UIViewController* vc = [[CTMediator sharedInstance] CTMediator_updateProfile:view.user];
        UINavigationController *nav = (UINavigationController *)[AWAppWindow() rootViewController];
        [nav pushViewController:vc animated:YES];
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadUserProfile)
                                                 name:@"kReloadUserProfileNotification"
                                               object:nil];
}

- (void)reloadUserProfile
{
    self.needReloadUserProfile = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [self loadData];
    
    // 每次进入个人中心的时候，获取一次最新的用户数据
//    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
//    [[UserService sharedInstance] loadUserProfileForAuthToken:token completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( self.needReloadUserProfile ) {
        [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
        
        NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
        [[UserService sharedInstance] loadUserProfileForAuthToken:token completion:^(User *aUser, NSError *error) {
            self.needReloadUserProfile = NO;
            [MBProgressHUD hideHUDForView:self.contentView animated:YES];
            
            if ( !error ) {
                self.profileView.user = [[UserService sharedInstance] currentUser];
            }
        }];
    }
    
}

- (void)loadData
{
    self.profileView.user = [[UserService sharedInstance] currentUser];
    
    [[UserService sharedInstance] loadUserSettingsForAuthToken:[[UserService sharedInstance] currentUser].authToken
                                                    completion:
     ^(NSArray<NSArray *> *result, NSError *error) {
         self.dataSource = result;
         [self.tableView reloadData];
     }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataSource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
    }
    
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    if ( indexPath.section == 3 ) {
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UINavigationController* nav = (UINavigationController *)[AWAppWindow() rootViewController];
    
    BOOL isLogined = [[UserService sharedInstance] isLoginedForUser:nil];
    if ( isLogined ) {
        if ( indexPath.section == 0 && indexPath.row == 0 ) {
            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openWalletVCForUser:nil];
            
            [nav pushViewController:vc animated:YES];
        } else if ( indexPath.section == 0 && indexPath.row == 1 ) {
            UIViewController *vc = [[CTMediator sharedInstance] CTMediator_openGrantsVC];
            [nav pushViewController:vc animated:YES];
        } else if ( indexPath.section == [self.dataSource count] - 1 && indexPath.row == 0 ) {
            // 退出登陆
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"您确定吗？"
                                       message:@""
                                      delegate:self
                             cancelButtonTitle:nil
                             otherButtonTitles:@"确定", @"取消", nil];
            [alert show];
        } else if ( indexPath.section == 1 ) {
            if ( indexPath.row == 0 ) {
                // 上传
                UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openUploadVCWithAuthToken:nil];
                [nav pushViewController:vc animated:YES];
            } else if ( indexPath.row == 1 ) {
                // 我的上传
                UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openUploadListVCWithAuthToken:nil];
                [nav pushViewController:vc animated:YES];
            }
        } else {
            [self didSelectAtIndex:indexPath.row];
        }
    } else {
        if ( indexPath.row == 0 ) {
            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openUploadVCWithAuthToken:nil];
            [nav pushViewController:vc animated:YES];
        } else {
            [self didSelectAtIndex:indexPath.row - 1];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 0 ) {
        [[UserService sharedInstance] logoutWithAuthToken:nil completion:^(id result, NSError *error) {
            
                                               }];
                                               [self loadData];
    }
}

- (void)didSelectAtIndex:(NSInteger)index;
{
    UINavigationController* nav = (UINavigationController *)[AWAppWindow() rootViewController];
    
    switch (index) {
//        case 0:
//        {
//            // 上传
//            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openUploadVCWithAuthToken:nil];
//            [nav pushViewController:vc animated:YES];
//        }
//            break;
        case 0:
        {
            // 收藏
            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openLikesVCForUser:nil];
            [nav pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            // 播放历史
            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openViewHistoryVCWithAuthToken:nil];
            [nav pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            // 清理缓存
            [SimpleToast showText:@"缓存清理成功"];
        }
            break;
        case 3:
        {
            // 意见反馈
            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openFeedbackVC];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case 4:
        {
            // 关于
            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openAboutVC];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView* view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header.id"];
    if ( !view ) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header.id"];
        view.contentView.backgroundColor = AWColorFromRGB(211, 212, 213);
    }
    return view;
}

@end
