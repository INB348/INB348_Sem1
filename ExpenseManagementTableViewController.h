//
//  ExpenseManagementTableViewController.h
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GroupTabBarController.h"
#import "HistoryNavigationViewController.h"
#import "NewExpenseNavigationController.h"
#import "EditExpenseNavigationController.h"
#import "EditExpenseViewController.h"

@interface ExpenseManagementTableViewController : UITableViewController <EditExpenseViewController, NewExpenseNavigationController>
- (IBAction)back:(id)sender;

@end
