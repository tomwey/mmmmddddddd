//
//  ViewHistory.h
//  zgnx
//
//  Created by tangwei1 on 16/5/31.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <CTPersistance/CTPersistance.h>

// 历史记录
//"id": 13,
//"title": "dddds",
//"video_file": "http://cdn.yaying.tv/uploads/video/file/13/c15cde82-d755-4668-9b1a-ce3e641bdab5.mp4?e=1464662332&token=hsFmU-AeAxLxZJyZJL1YnQwbTVMd7KuBbMdEjlO1:coC2pKuAq3kWjxThW-pSJn5Vjpg=",
//"cover_image": "http://cdn.yaying.tv/uploads/video/file/13/cover_image_c15cde82-d755-4668-9b1a-ce3e641bdab5.jpg?e=1464662332&token=hsFmU-AeAxLxZJyZJL1YnQwbTVMd7KuBbMdEjlO1:iYFx-AtcxeZtKirCmAn0svhfzag=",
//"view_count": 0,
//"likes_count": 0,
//"type": 2,
//"msg_count": 0,
//"stream_id": "65d409df592143ebb360ebb05557abef",
//"created_on": "2016-05-26"

// 控制器
//#import "LiveViewController.h"
//#import "VODListViewController.h"
//#import "UserViewController.h"
@class User;
@interface ViewHistory : CTPersistanceRecord <CTPersistanceRecordProtocol>

@property (nonatomic, copy) NSNumber* vid;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* video_file;
@property (nonatomic, copy) NSString* cover_image;
@property (nonatomic, copy) NSNumber* view_count;
@property (nonatomic, copy) NSNumber* likes_count;
@property (nonatomic, copy) NSNumber* msg_count;
@property (nonatomic, copy) NSNumber* video_id;
@property (nonatomic, copy) NSNumber* type;
@property (nonatomic, copy) NSString* stream_id;
@property (nonatomic, copy) NSString* created_on;
@property (nonatomic, copy) NSNumber* currentPlaybackTime;
@property (nonatomic, strong) User* loginedUser;

@end
