//
//  UserExpenseHistoryTableViewController.h
//  INB348
//
//  Created by Kristian M Matzen on 25/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EditExpenseNavigationController.h"
#import "EditExpenseViewController.h"
#import "HistoryCell.h"

@interface UserExpenseHistoryTableViewController : UITableViewController <EditExpenseViewController>
@property (strong) NSArray *groupUsers;
@property (strong) PFObject *groupUser;
- (IBAction)back:(id)sender;
@property (strong) PFObject *group;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *balanceLabel;

@end
