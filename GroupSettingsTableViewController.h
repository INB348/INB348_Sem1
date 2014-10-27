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
#import "MembersTableViewController.h"
@interface GroupSettingsTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITextField *nameLabel;
- (IBAction)deleteGroup:(id)sender;
- (IBAction)nameChanged:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)add:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *usernameLabel;

@end
