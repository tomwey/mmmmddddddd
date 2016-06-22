//
//  TestViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/6/3.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "TestViewController.h"
#import "Defines.h"
#import "VideoStreamDetailViewController.h"
#import <QiniuSDK.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface TestViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@end
@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton* btn = AWCreateImageButton(nil, self, @selector(click));
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(50, 50, 100, 40);
    
    self.thumbnailView = [[UIImageView alloc] init];
    [self.view addSubview:self.thumbnailView];
    self.thumbnailView.frame = CGRectMake(50, 100, 100, 100);
    
//    hsFmU-AeAxLxZJyZJL1YnQwbTVMd7KuBbMdEjlO1:N9FEuUG9LeG6ZsA4zetVZCxkfB8=:eyJzY29wZSI6Inpnbnl0djp0ZXN0Lm1wNCIsImRlYWRsaW5lIjoxNDY2NTgxMDU5fQ==
}

- (void)click
{
//    VideoStreamDetailViewController* vsdvc = [[VideoStreamDetailViewController alloc] init];
//    [self presentViewController:vsdvc animated:YES completion:nil];
//    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
//    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    pickerController.delegate   = self;
//    [self presentViewController:pickerController animated:YES completion:nil];
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
//    videoPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self presentViewController:videoPicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"info: %@", info);
//    UIImagePickerControllerMediaType = "public.movie";
//    UIImagePickerControllerMediaURL = "file:///private/var/mobile/Applications/CDBCF96C-D0BC-4FF1-A5A7-E72317156F38/tmp/trim.535F682C-B779-482A-A7C9-C1E3CD458CD7.MOV";
//    UIImagePickerControllerReferenceURL = "assets-library://asset/asset.mp4?id=4D31FDA0-AEED-44DF-AA4C-241F7D8E5CD9&ext=mp4";
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    
//    [self generateThumbnailFromVideoAtURL:videoURL completion:^(UIImage *image, NSError *error) {
//        if ( !error ) {
//            self.thumbnailView.image = image;
//        }
//    }];
    
    NSString *token = @"hsFmU-AeAxLxZJyZJL1YnQwbTVMd7KuBbMdEjlO1:455w1D8bMFV5Sx9Je-IApNtsQz0=:eyJzY29wZSI6Inpnbnl0djp1cGxvYWRzL3ZpZGVvL3Rlc3QxMjMzMjEubXA0IiwiZGVhZGxpbmUiOjE0NjY1ODQzOTl9";
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSData *data = [NSData dataWithContentsOfURL:videoURL];
    QNUploadOption *option = [[QNUploadOption alloc] initWithProgressHandler:^(NSString *key, float percent) {
        NSLog(@"percent: %f", percent);
    }];
    
    [upManager putData:data
                   key:@"uploads/video/test123321.mp4"
                 token:token
              complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  //
                  NSLog(@"info: %@, key: %@, resp: %@", info, key, resp);
              } option:option];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)generateThumbnailFromVideoAtURL:(NSURL *)contentURL completion:(void (^)(UIImage *image, NSError *error))completion
{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:contentURL options:nil];
    
    self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMake(1, 60);
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        UIImage *newImage = [[UIImage alloc] initWithCGImage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completion ) {
                completion(newImage, error);
            }
        });
    }];
    
//    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    
//    theImage = [[UIImage alloc] initWithCGImage:imgRef];
    
//    CGImageRelease(imgRef);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
