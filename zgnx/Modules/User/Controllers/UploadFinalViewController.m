//
//  UploadFinalViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/6/22.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UploadFinalViewController.h"
#import "Defines.h"

@interface UploadFinalViewController ()

@end

@implementation UploadFinalViewController

- (instancetype)initWithCoverImage:(UIImage *)coverImage fileName:(NSString *)filename
{
    if ( self = [super init] ) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"视频简介";
    
    
}


@end
