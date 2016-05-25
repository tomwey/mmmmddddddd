//
//  VODListViewController.m
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "VODListViewController.h"
#import "Defines.h"
#import "CatalogService.h"
#import "PagerTabStripper.h"

@interface VODListViewController ()

@end
@implementation VODListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        [self createTabBarItemWithTitle:@"推荐"
                                  image:nil
                          selectedImage:nil
                    titleTextAttributes:@{ NSFontAttributeName : AWSystemFontWithSize(16, NO) }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PagerTabStripper* stripper = [[PagerTabStripper alloc] init];
    [self.contentView addSubview:stripper];
    stripper.frame = CGRectMake(0, 0, AWFullScreenWidth(), 44);
    stripper.backgroundColor = AWColorFromRGB(227, 227, 227);
    
    stripper.titleColor = [UIColor blackColor];
    stripper.titleFont  = AWSystemFontWithSize(15, NO);
    
    stripper.selectedIndicatorSize = 1.1;
    stripper.selectedTitleColor = stripper.selectedIndicatorColor = [UIColor redColor];
    
    
    [[CatalogService sharedInstance] loadCatalogsWithCompletion:^(id results, NSError *error) {
        NSLog(@"%@ -> %@", results, error);
        NSMutableArray* temp = [NSMutableArray array];
        for (id dict in results[@"data"]) {
            [temp addObject:dict[@"name"]];
        }
        stripper.titles = temp;
    }];
}

@end
