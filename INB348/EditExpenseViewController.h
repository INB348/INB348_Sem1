//
//  EditExpenseViewController.h
//  INB348
//
//  Created by Kristian M Matzen on 11/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EditOptionsTableViewController.h"

@protocol EditExpenseViewController
- (void)refresh;
@end

@interface EditExpenseViewController : UIViewController <EditOptionsTableViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)deleteButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *amountTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (strong) PFObject *expense;
@property (strong) NSArray *oldExpenseParticipators;

@property (strong) PFObject *group;
@property (strong) NSArray *groupUsers;

@property (strong) NSMutableDictionary *paymentKeysAndMultipliers;
@property (strong) NSMutableDictionary *usageKeysAndMultipliers;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, assign) id <EditExpenseViewController> delegate;
@end
