//
//  ButtonGroup.h
//  zgnx
//
//  Created by tangwei1 on 16/6/3.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonGroup : UIView

- (instancetype)initWithFrame:(CGRect)frame
           buttonNormalImages:(NSArray<NSString *> *)normalImages
         buttonSelectedImages:(NSArray<NSString *> *)selectedImages;

@property (nonatomic, copy) NSArray<NSString *> *buttonNormalImages;
@property (nonatomic, copy) NSArray<NSString *> *buttonSelectedImages;

@property (nonatomic, copy) void (^didSelectItemBlock)(ButtonGroup *group);

@property (nonatomic, assign) NSUInteger selectedIndex;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end
