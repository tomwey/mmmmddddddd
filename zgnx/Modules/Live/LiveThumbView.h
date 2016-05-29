//
//  LiveThumbView.h
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveThumbView : UIView

@property (nonatomic, copy) NSDictionary* liveInfo;

@property (nonatomic, copy) void (^didSelectBlock)(LiveThumbView* view);

@end
