//
//  NewExpenseSummaryTableViewController.h
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NewExpenseSummaryTableViewController : UITableViewController
@property (strong) NSString  *name;
@property (strong) NSNumber  *amount;
@property (strong) NSDate  *date;
@property (strong) NSString *description;
@property (strong) NSArray *expensePayers;
@property (strong) NSArray *expenseUsers;
@property (strong) PFObject  *group;
- (IBAction)save:(id)sender;
@end
