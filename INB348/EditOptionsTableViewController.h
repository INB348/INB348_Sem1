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
-(void)expensePayerIndexes:(NSMutableDictionary *)indexesAndMultipliers;
-(void)expenseUserIndexes:(NSMutableDictionary *)indexesAndMultipliers;

@property (strong) NSMutableDictionary *paymentKeysAndMultipliers;
@property (strong) NSMutableDictionary *usageKeysAndMultipliers;
@end

@interface EditOptionsTableViewController : UITableViewController <EditExpenseParticipatorsTableViewController>
@property (strong) NSMutableArray *expensePayerIndexes;
@property (strong) NSMutableArray *expenseUserIndexes;
@property (strong) NSArray *groupUsers;

@property (nonatomic, assign) id <EditOptionsTableViewController> delegate;
@end
