//
//  NewExpenseDetailsViewController.h
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewExpenseWhoPaidTableViewController.h"

@interface NewExpenseDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (strong) PFObject  *group;
@property (strong) NSArray *groupUsers;
- (IBAction)cancel:(id)sender;
@end
