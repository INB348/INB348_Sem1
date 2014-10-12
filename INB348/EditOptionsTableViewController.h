//
//  EditOptionsTableViewController.h
//  INB348
//
//  Created by Kristian M Matzen on 11/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EditExpenseParticipatorsTableViewController.h"

@protocol EditOptionsTableViewController
-(void)expensePayerIndexes:(NSMutableArray *)indexes;
-(void)expenseUserIndexes:(NSMutableArray *)indexes;

@property (strong) NSMutableArray *expensePayerIndexes;
@property (strong) NSMutableArray *expenseUserIndexes;
@end

@interface EditOptionsTableViewController : UITableViewController <EditExpenseParticipatorsTableViewController>
@property (strong) NSMutableArray *expensePayerIndexes;
@property (strong) NSMutableArray *expenseUserIndexes;
@property (strong) NSArray *groupUsers;

@property (nonatomic, assign) id <EditOptionsTableViewController> delegate;
@end
