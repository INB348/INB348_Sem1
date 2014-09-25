//
//  BalanceManagementTableViewController.h
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GroupTabBarController.h"
#import "BalanceNavigationController.h"
#import "NewExpenseNavigationController.h"
#import "GroupUserCell.h"

@interface BalanceManagementTableViewController : UITableViewController
@property (nonatomic, strong) IBOutlet UITableView *groupUserTableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end
