//
//  NewExpenseWhoPaidTableViewController.h
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewExpenseNavigationController.h"
#import "SelectUsersCell.h"

@interface NewExpenseWhoPaidTableViewController : UITableViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>
- (IBAction)next:(id)sender;
@end
