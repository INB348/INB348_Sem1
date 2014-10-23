//
//  AddMemberToGroupViewController.h
//  INB348
//
//  Created by Kristian M Matzen on 10/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddMemberToGroupViewController : UIViewController
@property (strong) NSArray *groupUsers;
@property (strong) PFObject *group;
- (IBAction)cancel:(id)sender;
- (IBAction)add:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *usernameLabel;
@end
