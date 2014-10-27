//
//  EditExpenseParticipatorsTableViewController.h
//  INB348
//
//  Created by Kristian M Matzen on 11/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SelectUsersCell.h"

@protocol EditExpenseParticipatorsTableViewController
-(void)setExpenseParticipatorIndexes:(NSMutableDictionary *)indexesAndMultipliers;
@end

@interface EditExpenseParticipatorsTableViewController : UITableViewController
@property (strong) NSArray *groupUsers;
@property (strong) NSArray *selected;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
//@property (strong) NSMutableArray *indexes;
@property (strong) NSDictionary *keysAndMultipliers;

@property (nonatomic, assign) id <EditExpenseParticipatorsTableViewController> delegate;
@end
