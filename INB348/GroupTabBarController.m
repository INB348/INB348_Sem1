//
//  GroupTabBarController.m
//  INB348
//
//  Created by Kristian M Matzen on 23/09/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupTabBarController.h"
#import "BalanceNavigationController.h"
#import "BalanceManagementTableViewController.h"

@interface GroupTabBarController ()

@end

@implementation GroupTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
