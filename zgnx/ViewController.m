//
//  ViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/9.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "ViewController.h"
#import <AWTools/AWTools.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@", AWAppVersion());
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
