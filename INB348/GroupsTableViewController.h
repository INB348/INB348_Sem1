//
//  GroupsTableViewController.h
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "BalanceManagementTableViewController.h"
#import "GroupTabBarController.h"
#import "BalanceNavigationController.h"
#import "SWRevealViewController.h"
#import "GroupListCell.h"

@interface GroupsTableViewController : UITableViewController
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end
