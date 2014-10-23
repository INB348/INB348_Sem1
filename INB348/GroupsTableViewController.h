//
//  GroupsTableViewController.h
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "NewGroupViewController.h"
#import "BalanceManagementTableViewController.h"
#import "GroupTabBarController.h"
#import "BalanceNavigationController.h"

@interface GroupsTableViewController : UITableViewController <NewGroupViewController>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end
