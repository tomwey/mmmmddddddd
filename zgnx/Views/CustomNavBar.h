//
//  CustomNavBar.h
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavBar : UIView

@property (nonatomic, strong) UIImage* backgroundImage;

@property (nonatomic, strong) UIView* leftItem;
@property (nonatomic, strong) UIView* rightItem;

@property (nonatomic, copy)   NSString* title;
@property (nonatomic, strong) UIView*   titleView;

@end
