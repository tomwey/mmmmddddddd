//
//  VODListView.h
//  zgnx
//
//  Created by tangwei1 on 16/5/26.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VODListView : UIView

@property (nonatomic, copy) NSString* catalogID;

@property (nonatomic, copy) void (^reloadBlock)(BOOL succeed);

- (void)startLoadForPage:(NSUInteger)pageNo completion:( void (^)(BOOL succeed) )completion;

@end
