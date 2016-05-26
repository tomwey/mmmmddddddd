//
//  VideoListViewController.h
//  zgnx
//
//  Created by tangwei1 on 16/5/26.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoListViewController : UIViewController

+ (instancetype)videoListVCForPageIndex:(NSUInteger)index forCatalogID:(NSString *)catalogID;

@property (nonatomic, assign, readonly) NSUInteger pageIndex;

@end
