//
//  MediatorController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "MediatorController.h"
#import "UIViewController+AWFactoryMethods.h"

@interface MediatorController ()

@property (nonatomic, strong) UINavigationController* navController;

@end

@implementation MediatorController

+ (instancetype)sharedInstance
{
    static MediatorController* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[MediatorController alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    if ( self = [super init] ) {
        self.navController = [[UINavigationController alloc] init];
        self.navController.navigationBarHidden = YES;
        
        UITabBarController* tabBarController = [[UITabBarController alloc] init];
        [self.navController pushViewController:tabBarController animated:NO];
        
        tabBarController.viewControllers = @[[UIViewController viewControllerWithClassName:@"VODListViewController"],
                                             [UIViewController viewControllerWithClassName:@"LiveViewController"],
                                             [UIViewController viewControllerWithClassName:@"UserViewController"]];
    }
    return self;
}

- (UIViewController *)rootViewController
{
    return self.navController;
}

- (UIViewController *)openVC:(NSString *)controllerName withParams:(NSDictionary *)params
{
    
    return nil;
}

@end
