//
//  UserViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/25.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UserViewController.h"
#import "Defines.h"
#import "UserService.h"
#import "UserProfileView.h"
#import <AWTableView/UITableView+RemoveBlankCells.h>

@interface UserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* dataSource;

@property (nonatomic, copy) NSString* authToken;

@property (nonatomic, weak) UserProfileView* profileView;

@end
@implementation UserViewController

- (instancetype)initWithAuthToken:(NSString *)authToken
{
    if ( self = [super init] ) {
        self.authToken = authToken;
        
        [self createTabBarItemWithTitle:@"我的"
                                  image:[UIImage imageNamed:@"tab_me_n.png"]
                          selectedImage:[UIImage imageNamed:@"tab_me_s.png"]
           titleTextAttributesForNormal:nil
         titleTextAttributesForSelected:@{ NSForegroundColorAttributeName : AWColorFromRGB(20, 118, 255) }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.backgroundColor = AWColorFromRGB(224, 224, 224);
    
    self.tableView = [[UITableView alloc] initWithFrame:AWFullScreenBounds()
                                                  style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView removeBlankCells];
    
    self.tableView.tableHeaderView = [[UserProfileView alloc] init];
    
    self.profileView = (UserProfileView *) self.tableView.tableHeaderView;
    
    [[UserService sharedInstance] loadUserProfileForAuthToken:self.authToken
                                                   completion:
     ^(User *aUser, NSError *error) {
         self.profileView.user = aUser;
         
         [[UserService sharedInstance] loadUserSettingsForAuthToken:self.authToken
                                                         completion:
          ^(NSArray<NSArray *> *result, NSError *error) {
              self.dataSource = result;
              [self.tableView reloadData];
          }];
         
     }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataSource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
    }
    
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

@end
