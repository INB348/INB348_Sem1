//
//  NewExpenseNavigationController.h
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NewExpenseNavigationController : UINavigationController
@property (strong) NSString  *name;
@property (strong) NSNumber  *amount;
@property (strong) NSDate  *date;
@property (strong) NSArray *expensePayers;
@property (strong) NSArray *expenseUsers;
@property (strong) PFObject *group;
@property (strong) NSArray *groupUsers;
@property (strong) NSString *comment;

//If editing
@property (strong) PFObject *oldExpense;
@property (strong) NSArray *oldExpensePayers;
@property (strong) NSArray *oldExpenseUsers;
@end