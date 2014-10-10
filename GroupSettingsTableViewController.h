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
#import "AddMemberNavigationController.h"
#import "AddMemberToGroupViewController.h"

@interface GroupSettingsTableViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *nameLabel;
- (IBAction)deleteGroup:(id)sender;
- (IBAction)nameChanged:(id)sender;

@end
