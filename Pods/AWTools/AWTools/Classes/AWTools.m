//
//  AWTools.m
//  Pods
//
//  Created by tangwei1 on 16/5/9.
//
//

#import "AWTools.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "sys/utsname.h"

/**
 * 返回当前设备运行的iOS版本
 */
float AWOSVersion()
{
    return [AWOSVersionString() floatValue];
}

NSString* AWOSVersionString()
{
    return [[UIDevice currentDevice] systemVersion];
}

NSString* AWDeviceName()
{
    struct utsname name;
    uname(&name);
    
    NSString *machine = [NSString stringWithCString:name.machine encoding:NSUTF8StringEncoding];
    
    return machine;
}

NSString* AWDeviceSizeString()
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    NSUInteger width = AWFullScreenWidth() * scale;
    NSUInteger height = AWFullScreenHeight() * scale;
    
    return [NSString stringWithFormat:@"%lulx%lul", (unsigned long)width, (unsigned long)height];
}

/**
 * 检查当前设备运行的iOS版本是否小于给定的版本
 */
BOOL AWOSVersionIsLower(float version)
{
    return AWOSVersion() < version;
}

/**
 * 判断设备是否是iPad
 */
BOOL AWIsPad()
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

//BOOL AWIsKeyboardVisible()
//{
//    UIWindow* window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
//
//    return !![window findFirstResponder];
//}

/**
 * 返回全屏大小
 */
CGRect AWFullScreenBounds()
{
    return [[UIScreen mainScreen] bounds];
}

/**
 * 全屏宽
 */
CGFloat AWFullScreenWidth()
{
    return CGRectGetWidth(AWFullScreenBounds());
}

/**
 * 全屏高
 */
CGFloat AWFullScreenHeight()
{
    return CGRectGetHeight(AWFullScreenBounds());
}

/**
 * 获取一个矩形的中心点
 */
CGPoint AWCenterOfRect(CGRect aRect)
{
    return CGPointMake(CGRectGetMidX(aRect), CGRectGetMidY(aRect));
}

UIWindow* AWAppWindow()
{
    return [[[UIApplication sharedApplication] windows] objectAtIndex:0];
}

UIWindow* AWCreateAppWindow(UIColor* bgColor)
{
    UIWindow* anWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    anWindow.backgroundColor = bgColor;
    [anWindow makeKeyAndVisible];
    return anWindow;
}

void AWAppRateus(NSString* appId)
{
    NSString *url=nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        url=[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appId];
    }else{
        url=[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appId];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

NSString* AWAppVersion()
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

UIFont* AWSystemFontWithSize(CGFloat fontSize, BOOL isBold)
{
    if ( isBold ) {
        return [UIFont boldSystemFontOfSize:fontSize];
    }
    return [UIFont systemFontOfSize:fontSize];
}

UIFont* AWCustomFont(NSString* fontName, CGFloat fontSize)
{
    return [UIFont fontWithName:fontName size:fontSize];
}

UIColor* AWColorFromRGB(NSUInteger R, NSUInteger G, NSUInteger B)
{
    return AWColorFromRGBA(R, G, B, 1.0);
}

UIColor* AWColorFromRGBA(NSUInteger R, NSUInteger G, NSUInteger B, CGFloat A)
{
    return [UIColor colorWithRed:R / 255.0
                           green:G / 255.0
                            blue:B / 255.0
                           alpha:A];
}

UIColor* AWColorFromHex(NSString* hexString)
{
    unsigned rgbValue = 0;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    scanner.scanLocation = 1; // 跳过#字符
    [scanner scanHexInt:&rgbValue];
    return AWColorFromRGBA( ( ( rgbValue & 0xFF0000 ) >> 16 ), ( ( rgbValue & 0xFF00 ) >> 8 ), ( rgbValue & 0xFF ), 1.0);
}

UIImage* AWSimpleResizeImage(UIImage* srcImage, CGSize newSize)
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [[UIScreen mainScreen] scale]);
    [srcImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

void AWSaveImageToPhotosAlbum(UIImage* anImage, NSString* groupName, SaveImageCompletionBlock completionBlock)
{
    static ALAssetsLibrary* photoLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !photoLibrary ) {
            photoLibrary = [[ALAssetsLibrary alloc] init];
        }
    });
    
    [photoLibrary writeImageToSavedPhotosAlbum:anImage.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if ( error.code == 0 ) {
            [photoLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                if ( groupName ) {
                    [photoLibrary addAssetsGroupAlbumWithName:groupName resultBlock:^(ALAssetsGroup *group) {
                        if ( !group ) {
                            [photoLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                if ( [[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:groupName] ) {
                                    [group addAsset:asset];
                                    *stop = YES;
                                }
                            } failureBlock:^(NSError *error) {
                                NSLog(@"enumerate groups with error: %@", error);
                            }];
                        } else {
                            [group addAsset:asset];
                        }
                    } failureBlock:^(NSError *error) {
                        NSLog(@"add assets group with error: %@", error);
                    }];
                }
            } failureBlock:^(NSError *error) {
                NSLog(@"asset for url with error: %@", error);
            }];
            
            if ( completionBlock ) {
                completionBlock(YES, nil);
            }
            
        } else {
            if ( completionBlock ) {
                completionBlock(NO, error);
            }
        }
    }];
}

void AWSetAllTouchesDisabled(BOOL yesOrNo)
{
    if ( yesOrNo ) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    } else {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

UIButton* AWCreateImageButton(NSString* imageName, id target, SEL action)
{
    return AWCreateImageButtonWithSize(imageName, CGSizeZero, target, action);
}

UIButton* AWCreateImageButtonWithSize(NSString* imageName, CGSize size, id target, SEL action)
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button sizeToFit];
    
    button.exclusiveTouch = YES;
    
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    if ( CGRectContainsRect(bounds, button.bounds) ) {
        button.bounds = bounds;
    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

UIButton* AWCreateBackgroundImageAndTitleButton(NSString* backgroundImageName, NSString* title, id target, SEL action)
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage* backgroundImage = [UIImage imageNamed:backgroundImageName];
    
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    
    if ( backgroundImage ) {
        [[button titleLabel] setFont:AWSystemFontWithSize(backgroundImage.size.height * 0.3, NO)];
    } else {
        [[button titleLabel] setFont:AWSystemFontWithSize(24, NO)];
    }
    
    button.frame = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height);
    
    button.exclusiveTouch = YES;
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

UIButton* AWCreateTextButton(CGRect frame, NSString* title, UIColor* titleColor, id target, SEL action)
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    button.frame = frame;
    
    button.exclusiveTouch = YES;
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

UIBarButtonItem* AWCreateImageBarButtonItem(NSString* imageName, id target, SEL action)
{
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:AWCreateImageButton(imageName, target, action)];
    return item;
}

UIBarButtonItem* AWCreateImageBarButtonItemWithSize(NSString* imageName, CGSize size, id target, SEL action)
{
    UIBarButtonItem* item =
    [[UIBarButtonItem alloc] initWithCustomView:AWCreateImageButtonWithSize(imageName, size, target, action)];
    return item;
}

UIImageView* AWCreateImageView(NSString* imageName)
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [imageView sizeToFit];
    return imageView ;
}

UIImageView* AWCreateImageViewWithFrame(NSString* imageName, CGRect frame)
{
    UIImageView* imageView = AWCreateImageView(imageName);
    imageView.frame = frame;
    return imageView;
}

UILabel* AWCreateLabel(CGRect frame, NSString* text, NSTextAlignment alignment, UIFont* font, UIColor* textColor)
{
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = alignment;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    
    label.text = text;
    
    return label;
}

UITableView* AWCreateTableView(CGRect frame, UITableViewStyle style, UIView* superView, id <UITableViewDataSource> dataSource)
{
    UITableView* tableView = [[UITableView alloc] initWithFrame:frame style:style];
    [superView addSubview:tableView];
    
    tableView.dataSource = dataSource;
    
    return tableView;
}

UIView* AWCreateLine(CGSize size, UIColor* color)
{
    return AWCreateLineInView(size, color, nil);
}

UIView* AWCreateLineInView(CGSize size, UIColor* color, UIView* containerView)
{
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    line.backgroundColor = color;
    if ( containerView ) {
        [containerView addSubview:line];
    }
    return line;
}