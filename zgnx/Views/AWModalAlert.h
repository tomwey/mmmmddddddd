//
//  ModalAlert.h
//  CountDown
//
//  Created by tang.wei on 14-4-28.
//  Copyright (c) 2014年 tang.wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AWModalAlert : NSObject

// Yes-No button
+ (void) ask:(NSString *)message result:( void (^)(BOOL yesOrNo) )result;
+ (void) ask:(NSString *)title message:(NSString *)message result:( void (^)(BOOL yesOrNo) )result;

// OK-Cancel button
+ (void) confirm:(NSString *)message result:( void (^)(BOOL okOrCancel) )result;
+ (void) confirm:(NSString *)title message:(NSString *)message result:( void (^)(BOOL okOrCancel) )result;

// OK
+ (void) say:(id)formatString,...;
+ (void) say:(NSString *)title message:(id)formatString,...;

// Other
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
         cancelButton:(NSString *)cancel
         otherButtons:(NSArray *)otherButtons
               result:( void (^)(NSUInteger buttonIndex) )result;

@end

