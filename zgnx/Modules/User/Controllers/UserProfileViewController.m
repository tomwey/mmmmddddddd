//
//  UserProfileViewController.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "UserProfileViewController.h"
#import "Defines.h"
#import "LoadDataService.h"

@interface UserProfileViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UITextField *nicknameTextField;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) LoadDataService *dataService;

@property (nonatomic, weak) UIImageView *avatarView;

@end

@implementation UserProfileViewController

- (instancetype)initWithUser:(User *)user
{
    if ( self = [super init] ) {
        self.user = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"编辑资料";
    self.navBar.rightItem = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
                                               @"保存",
                                               [UIColor whiteColor],
                                               self, @selector(save));
    
    UIImageView *avatarView = AWCreateImageView(nil);
    [self.contentView addSubview:avatarView];
    avatarView.frame = CGRectMake(0, 0, 60, 60);
    avatarView.layer.cornerRadius = avatarView.height / 2;
    avatarView.clipsToBounds = YES;
    
    [avatarView setImageWithURL:[NSURL URLWithString:self.user.avatarUrl]
               placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    avatarView.userInteractionEnabled = YES;
    self.avatarView = avatarView;
    
    UIButton *blankBtn = AWCreateImageButton(nil, self, @selector(updateAvatar));
    blankBtn.frame = avatarView.bounds;
    [avatarView addSubview:blankBtn];
    
    avatarView.center = CGPointMake(self.contentView.width / 2, 20 + avatarView.height / 2);
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, avatarView.bottom + 20,
                                                                     self.contentView.width,
                                                                     50)];
    [self.contentView addSubview:containerView];
    containerView.backgroundColor = [UIColor whiteColor];
    
    // 昵称
    UILabel *nickname = AWCreateLabel(CGRectMake(15, 8, 50,
                                                 34),
                                      @"昵称",
                                      NSTextAlignmentLeft,
                                      nil,
                                      nil);
    [containerView addSubview:nickname];
 
    self.nicknameTextField = [[UITextField alloc] initWithFrame:CGRectMake(nickname.right + 5,
                                                                           nickname.top,
                                                                           self.contentView.width - 40 - nickname.width,
                                                                           34)];
    [containerView addSubview:self.nicknameTextField];
    self.nicknameTextField.placeholder = @"输入昵称";
    self.nicknameTextField.text = self.user.nickname;
}

- (void)updateAvatar
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"从相册选择", @"拍照",nil];
    [actionSheet showInView:self.contentView];
}

- (void)save
{
    NSString *nickname = [self.nicknameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ( [nickname length] == 0 ) {
        return;
    }
    
    [self.nicknameTextField resignFirstResponder];
    
    __weak typeof(self) me = self;
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
    [self.dataService POST:API_USER_UPDATE_NICKNAME params:@{ @"token": token,
                                                              @"nickname": nickname
                                                              } completion:^(id result, NSError *error) {
                                                                  [MBProgressHUD hideHUDForView:me.contentView animated:YES];
                                                                  if ( error ) {
                                                                      [[Toast showText:error.domain] setBackgroundColor: NAV_BAR_BG_COLOR];
                                                                  } else {
                                                                      me.user.nickname = nickname;
                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"kReloadUserProfileNotification" object:nil];
                                                                      [me.navigationController popViewControllerAnimated:YES];
                                                                  }
                                                              }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 0 ) {
        if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    } else if ( buttonIndex == 1 ) {
        if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    NSString *token = [[UserService sharedInstance] currentUser].authToken ?: @"";
    [self.dataService POST:API_USER_UPDATE_AVATAR params:@{ @"token": token,
                                                            @"avatar": UIImagePNGRepresentation(image)
                                                            } completion:^(id result, NSError *error) {
                                                                [MBProgressHUD hideHUDForView:me.contentView animated:YES];
                                                                if ( error ) {
                                                                    [[Toast showText:@"更新头像失败"] setBackgroundColor: NAV_BAR_BG_COLOR];
                                                                } else {
                                                                    me.avatarView.image = image;
                                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kReloadUserProfileNotification" object:nil];
                                                                }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (UIImagePickerController *)imagePickerController
{
    if ( !_imagePickerController ) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = YES;
    }
    return _imagePickerController;
}

- (LoadDataService *)dataService
{
    if ( !_dataService ) {
        _dataService = [[LoadDataService alloc] init];
    }
    return _dataService;
}

@end
