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
@interface GroupSettingsTableViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *img_Profile;
@property (strong, nonatomic) IBOutlet UITextField *usernameLabel;

- (IBAction)deleteGroup:(id)sender;
- (IBAction)nameChanged:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)selectPhoto:(UIButton *)sender;


@end
