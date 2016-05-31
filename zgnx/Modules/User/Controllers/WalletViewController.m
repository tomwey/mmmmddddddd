//
//  WalletViewController.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "WalletViewController.h"
#import "Defines.h"

@interface WalletViewController ()

@end

@implementation WalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"我的钱包";
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
