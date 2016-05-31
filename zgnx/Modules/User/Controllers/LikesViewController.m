//
//  LikesViewController.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "LikesViewController.h"
#import "Defines.h"

@interface LikesViewController () <ReloadDelegate>

@end

@implementation LikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"我的收藏";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadDataForErrorOrEmpty];
    });
}

- (void)reloadDataForErrorOrEmpty
{
    [self.dataSource.tableView removeErrorOrEmptyTips];
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    [[UserService sharedInstance] loadUserLikedVideosWithPage:-1 completion:^(id result, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.contentView animated:YES];
        
        if ( error ) {
            [self.dataSource.tableView showErrorOrEmptyMessage:@"加载数据失败，请重试！" reloadDelegate:self];
        } else {
            if ( [result count] > 0 ) {
                self.dataSource.dataSource = result;
            } else {
                [self.dataSource.tableView showErrorOrEmptyMessage:@"Oops，您还未收藏过！" reloadDelegate:self];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
