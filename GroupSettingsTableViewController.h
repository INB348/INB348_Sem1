//
//  GroupSettingsTableViewController.h
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GroupTabBarController.h"
#import "GroupSettingsNavigationViewController.h"

@interface GroupSettingsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITextField *nameLabel;
- (IBAction)addMember:(id)sender;
- (IBAction)deleteGroup:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *membersTableView;

@end
