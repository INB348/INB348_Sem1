//
//  BalanceManagementTableViewController.h
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "NewExpenseDetailsViewController.h"
#import "NewExpenseNavigationController.h"


@interface BalanceManagementTableViewController : UITableViewController
@property (nonatomic, strong) IBOutlet UITableView *groupUserTableView;
@property (strong) PFObject  *group;
@end
