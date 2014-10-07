//
//  GroupTabBarController.m
//  INB348
//
//  Created by Kristian M Matzen on 23/09/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupTabBarController.h"

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
    [self refresh];
}

- (void)refresh{
    //Retrieving GroupUser list
    PFQuery *groupUsersQuery = [PFQuery queryWithClassName:@"UserGroup"];
    [groupUsersQuery includeKey:@"user"];
    [groupUsersQuery whereKey:@"group" equalTo:self.group];
    [groupUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d UserGroups.", objects.count);
            
            // Do something with the found objects
            self.groupUsers = [objects mutableCopy];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    PFQuery *expensesQuery = [PFQuery queryWithClassName:@"Expense"];
    [expensesQuery whereKey:@"group" equalTo:self.group];
    [expensesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d Expenses.", objects.count);
            
            // Do something with the found objects
            self.expenses = [objects mutableCopy];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
