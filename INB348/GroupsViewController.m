//
//  GroupsViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 23/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupsViewController.h"

@interface GroupsViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}



@end
