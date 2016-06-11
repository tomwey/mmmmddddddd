//
//  BiliView.h
//  zgnx
//
//  Created by tomwey on 6/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bilibili;
@interface BiliView : UIView

@property (nonatomic, copy) NSString *streamId;

@property (nonatomic, copy) void (^didSendBiliBlock)(BiliView *view, Bilibili *bili);

@end
