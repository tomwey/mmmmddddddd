//
//  BannerView.h
//  zgnx
//
//  Created by tomwey on 6/2/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BannerView : UIView

- (void)startLoading:(void (^)(id selectItem))selectCallback;

- (void)startLoading:(void (^)(id selectItem))selectCallback
  completionCallback:(void (^)(NSArray *result, NSError *error))completion;

@property (nonatomic, copy) NSString *categoryId;

@end
