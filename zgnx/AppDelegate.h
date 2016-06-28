//
//  AppDelegate.h
//  zgnx
//
//  Created by tangwei1 on 16/5/9.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMSManager;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) DMSManager *dmsManager;
@end

