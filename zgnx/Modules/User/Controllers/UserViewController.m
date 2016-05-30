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

@interface UserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* dataSource;

@property (nonatomic, copy) NSString* authToken;

@property (nonatomic, weak) UserProfileView* profileView;

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
    
    if ( [self respondsToSelector:@selector(setEdgesForExtendedLayout:)] ) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.tableView = [[UITableView alloc] initWithFrame:AWFullScreenBounds()
                                                  style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView removeBlankCells];
    
    UserProfileView* upv = [[UserProfileView alloc] init];
    self.tableView.tableHeaderView = upv;
    
    self.profileView = upv;
    
    __weak typeof(self) weakSelf = self;
    self.profileView.didClickBlock = ^(UserProfileView* view) {
        UIViewController* vc = [[CTMediator sharedInstance] CTMediator_updateProfile:view.user];
        [weakSelf presentViewController:vc animated:YES completion:nil];
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
    
    if ( indexPath.section == 2 ) {
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
        } else if ( indexPath.section == 2 && indexPath.row == 0 ) {
            [[UserService sharedInstance] logoutWithAuthToken:nil completion:^(id result, NSError *error) {
                
            }];
            [self loadData];
        } else {
            [self didSelectAtIndexPath:indexPath];
        }
    } else {
        [self didSelectAtIndexPath:indexPath];
    }
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController* nav = (UINavigationController *)[AWAppWindow() rootViewController];
    
    switch (indexPath.row) {
        case 0:
        {
            // 上传
            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openUploadVCWithAuthToken:nil];
            [nav pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            // 收藏
            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openLikesVCForUser:nil];
            [nav pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            // 播放历史
            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openViewHistoryVCWithAuthToken:nil];
            [nav pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            // 清理缓存
            
        }
            break;
        case 4:
        {
            // 意见反馈
            UIViewController* vc = [[CTMediator sharedInstance] CTMediator_openFeedbackVC];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case 5:
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
