//
//  VideoCell.h
//  zgnx
//
//  Created by tangwei1 on 16/5/26.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWTableView/AWTableDataConfig.h>

FOUNDATION_EXTERN NSString * const kVideoCellDidSelectNotification;
FOUNDATION_EXTERN NSString * const kVideoCellDidDeleteNotification;

@class Stream;
@interface VideoCell : UITableViewCell <AWTableDataConfig>

//@property (nonatomic, strong, readonly) id cellData;

@property (nonatomic, strong, readonly) Stream *stream;

@property (nonatomic, copy) void (^didSelectItem)(VideoCell* cell);

+ (CGFloat)cellHeight;

@end
