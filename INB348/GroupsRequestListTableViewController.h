//
//  GroupsRequestListTableViewController.h
//  INB348
//
//  Created by Kristian M Matzen on 23/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GroupRequestCell.h"

@interface GroupsRequestListTableViewController : UITableViewController <GroupRequestCell>
- (IBAction)back:(id)sender;
@property (strong) NSArray *requestedGroupUsers;
@end
