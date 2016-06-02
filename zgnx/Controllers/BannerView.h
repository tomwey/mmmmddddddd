//
//  BannerView.h
//  zgnx
//
//  Created by tomwey on 6/2/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BannerView : UIView

- (void)startLoading:(void (^)(void))callback;

@end
