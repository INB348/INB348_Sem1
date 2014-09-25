//
//  LogInViewController.h
//  INB348
//
//  Created by nOrJ on 10/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupsTableNavigationController.h"
#import "GroupsTableViewController.h"

@interface LogInViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UITextField *txt_Email;

@property (nonatomic, strong) IBOutlet UITextField *txt_Password;


-(IBAction)logInPressed:(id)sender;

@end
