//
//  StaticToolbar.h
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaticToolbar : UIView

- (instancetype)initWithViewCount:(NSInteger)viewCount
                       likesCount:(NSInteger)likesCount
                        biliCount:(NSInteger)biliCount;

@end
