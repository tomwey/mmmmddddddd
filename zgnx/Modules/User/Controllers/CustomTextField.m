//
//  CustomTextField.m
//  zgnx
//
//  Created by tomwey on 5/30/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "CustomTextField.h"
#import "Defines.h"

@implementation CustomTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.backgroundColor = AWColorFromRGB(236,236,236);
        
        self.layer.cornerRadius = 6;
        self.layer.borderColor = [AWColorFromRGB(189,189,189) CGColor];
        self.layer.borderWidth = .8;
        
        self.clipsToBounds = YES;
        
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

@end
